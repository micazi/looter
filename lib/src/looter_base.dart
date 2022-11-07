// ignore_for_file: public_member_api_docs, sort_constructors_first, no_leading_underscores_for_local_identifiers

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import 'Helpers/exports.helper.dart';
import 'Models/exports.model.dart';

///
/// A simple yet fully-featured web scraper for both static and dynamically generated web pages.
///
class Looter {
  static Looter? _instance;
  //
  final CrawlingMethod _method;
  final Browser? _browser;
  final http.Client? _client;

  ///
  /// Initialize the looter with either static crawler or dynamic one, for static HTML content and
  /// server/js generated content respectively.
  ///
  static Future<Looter> initialize(
      {CrawlingMethod crawlingMethod = CrawlingMethod.staticCrawler}) async {
    if (_instance == null) {
      Browser? browser;
      http.Client? client;
      if (crawlingMethod == CrawlingMethod.dynamicCrawler) {
        browser = await initializeBrowser();
      } else {
        client = http.Client();
      }
      _instance = Looter._(crawlingMethod, browser, client);
    }
    return _instance!;
  }

  Looter._(CrawlingMethod method, Browser? browser, http.Client? client)
      : _browser = browser,
        _client = client,
        _method = method;

  ///
  /// Instantiates a crawling request that takes in the url target and resturn a [LootResult] object
  ///
  Future<LootResult> from(
    String url, {
    Until? waitUntil,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_method == CrawlingMethod.dynamicCrawler) {
      Page page = await _browser!.newPage();
      late LootResult _return;
      Response response =
          await page.goto(url, timeout: timeout, wait: waitUntil);
      _return = LootResult(
        status: response.status,
        headers: response.headers,
        content: await response.content,
      );
      await page.close();
      return _return;
    } else {
      Uri uri = Uri.parse(url);
      http.Response _response = await _client!.get(uri);
      return LootResult(
        status: _response.statusCode,
        headers: _response.headers,
        content: _response.body,
      );
    }
  }

  ///
  /// Loot a single element with a selector and optionally give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', elementIdentifier: "bookTitle");
  ///```
  static LootElement? loot(dynamic input, String selector,
      {String? elementIdentifier}) {
    Element? element;
    try {
      Document parsedData = parse(input);
      element = parsedData.querySelector(selector);
    } catch (e) {
      print("Error in parsing the input : $e");
    }

    return element != null
        ? LootElement.fromElement(element, elementIdentifier ?? "")
        : null;
  }

  ///
  /// Loot multible elements with a selector and optionally give it a unique identifier to harvest.
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///  ```dart
  ///  List<LootElement?> result = await looter
  ///      .from("http://books.toscrape.com")
  ///      .lootAll('article.product_pod h3 a', elementIdentifier: "bookTitle");
  ///```
  ///
  static List<LootElement?> lootAll(dynamic input, String selector,
      {String? elementIdentifier}) {
    List<Element>? elements;
    try {
      Document parsedData = parse(input);
      elements = parsedData.querySelectorAll(selector);
    } catch (e) {
      print("Error in parsing the input : $e");
    }

    List<LootElement> _return = [];
    for (var i = 0; i < elements!.length; i++) {
      Element e = elements[i];
      _return.add(LootElement.fromElement(e, "${elementIdentifier ?? ''}#$i"));
    }

    return _return;
  }

  ///
  /// Loop over multible parents with a shared selector and get children elements as a list of mapped objects
  /// Takes in a 2 dimensioned map: Map<'elementSelector', Map<'elementIdentifier' : 'elementProperty'>>
  /// Returns [List<Map<String,dynamic>>]: Map<'elementIdenifier' : 'value'>.
  ///```dart
  ///  List<Map<String, dynamic>> result =
  ///      await looter.from("http://books.toscrape.com").loop(
  ///    'ol.row li', // give the looper the shared parents selector..
  /// {
  ///       'article.product_pod h3 a': {"bookTitle": 'text'},
  ///       'div.image_container img': {"bookImage": 'src'},
  ///       'div.product_price p.price_color': {'bookPrice': 'text'},
  ///       'div.product_price instock availability': {'bookAvailability': 'text'},
  ///     },
  ///  );
  ///```
  ///
  static List<Map<String, dynamic>> loop(
    dynamic input,
    String parentSelector,
    Map<String, Map<String, String?>> targets,
  ) {
    List<Map<String, dynamic>> _return = [];
    List<LootElement?> _parents =
        lootAll(input, parentSelector).where((e) => e != null).toList();
    for (var i = 0; i < _parents.length; i++) {
      LootElement pElement = _parents[i]!;
      Map<String, dynamic> _object = {};
      targets.forEach((_targetSelector, _targetMap) {
        _targetMap.forEach((_targetName, _targetModifier) {
          if (_targetModifier != null && _targetModifier.startsWith('array:')) {
            List<Element> _elements =
                pElement.toElement().querySelectorAll(_targetSelector);
            List<LootElement> _childElements = [];
            for (var ss = 0; ss < _elements.length; ss++) {
              Element _s = _elements[ss];
              _childElements
                  .add(LootElement.fromElement(_s, '$_targetName#$i-ss'));
            }
            late dynamic _modifiedElements;
            if (_targetModifier.split('array:')[1] != "") {
              String _mod = _targetModifier.split('array:')[1];
              if (_mod == "text") {
                _modifiedElements = _childElements.map((e) => e.text).toList();
              } else {
                _modifiedElements =
                    _childElements.map((e) => e.attributes?[_mod]).toList();
              }
            } else {
              _modifiedElements = _childElements;
            }
            _object.addEntries([
              MapEntry(
                _targetName,
                _modifiedElements,
              )
            ]);
          } else {
            LootElement? _childElement = LootElement.fromElement(
                pElement.toElement().querySelector(_targetSelector),
                "$_targetName#$i");
            late dynamic _modifiedElement;
            if (_targetModifier != null) {
              if (_targetModifier == "text") {
                _modifiedElement = _childElement.text;
              } else {
                _modifiedElement = _childElement.attributes?[_targetModifier];
              }
            } else {
              _modifiedElement = _childElement;
            }
            _object.addEntries([
              MapEntry(
                _targetName,
                _modifiedElement,
              )
            ]);
          }
        });
      });
      _return.add(_object);
    }
    return _return;
  }
}
