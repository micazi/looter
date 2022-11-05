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
      Response response =
          await page.goto(url, timeout: timeout, wait: waitUntil);
      return LootResult(
        status: response.status,
        headers: response.headers,
        content: await response.content,
      );
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
  /// Loot a single element with a selector and give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', "bookTitle");
  ///```
  static LootElement? loot(
      dynamic input, String selector, String elementIdentifier) {
    Element? element;
    try {
      Document parsedData = parse(input);
      element = parsedData.querySelector(selector);
    } catch (e) {
      print("Error in parsing the input : $e");
    }

    return element != null
        ? LootElement.fromElement(element, elementIdentifier)
        : null;
  }

  ///
  /// Loot multible elements with a selector and give it a unique identifier to harvest.
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///  ```dart
  ///  List<LootElement?> result = await looter
  ///      .from("http://books.toscrape.com")
  ///      .lootAll('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  static List<LootElement?> lootAll(
      dynamic input, String selector, String elementIdentifier) {
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
      _return.add(LootElement.fromElement(e, "$elementIdentifier#$i"));
    }

    return _return;
  }

  ///
  /// Loop over multible parents with a shared selector and get children elements of earch with a map {identifier:selector}
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///```dart
  ///  List<LootElement?> result =
  ///      await looter.from("http://books.toscrape.com").lootLoop(
  ///    'ol.row li', // give the looper the shared parents selector..
  ///    {
  ///      // give it a map of identifiers (to identify later from the list of elements
  ///      // as 'identifier#parentnumber) and a child selector.'
  ///      "bookTitle": "article.product_pod h3 a",
  ///      "bookPrice": "div.product_price p.price_color",
  ///      "bookAvailability": "div.product_price instock availability",
  ///    },
  ///  );
  ///   // filter the list by element identifiers like this:
  ///  LootElement? elementIWant = result
  ///      .where(
  ///        (e) => e?.elementIdentifier == "bookTitle#5",
  ///     )
  ///      .single;
  ///```
  ///
  static List<LootElement?> lootLoop(
    dynamic input,
    String parentSelector,
    Map<String, String> childrenSelectors,
  ) {
    List<LootElement?> _return = [];
    List<LootElement?> parents = lootAll(input, parentSelector, "parent")
        .where((e) => e != null)
        .toList();
    for (var i = 0; i < parents.length; i++) {
      LootElement pElement = parents[i]!;
      childrenSelectors.forEach((_title, _selector) {
        LootElement? _childElement = LootElement.fromElement(
            pElement.toElement().querySelector(_selector), "$_title#$i");
        _return.add(_childElement);
      });
    }
    return _return;
  }
}
