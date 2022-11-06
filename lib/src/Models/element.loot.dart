// ignore_for_file: public_member_api_docs, sort_constructors_first, depend_on_referenced_packages

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:html/dom.dart';

import '../looter_base.dart';

class LootElement {
  String elementIdentifier;
  //
  String outerHTML;
  String innerHTML;
  //
  String? id;
  List<String>? classNames;
  Map<String, String>? attributes;
  //--
  String tagName;
  String? text;
  //--
  LootElement({
    required this.elementIdentifier,
    required this.outerHTML,
    required this.innerHTML,
    this.id,
    this.classNames,
    this.attributes,
    required this.tagName,
    this.text,
  });

  LootElement copyWith({
    String? elementIdentifier,
    String? outerHTML,
    String? innerHTML,
    String? id,
    List<String>? classNames,
    Map<String, String>? attributes,
    String? tagName,
    String? text,
  }) {
    return LootElement(
      elementIdentifier: elementIdentifier ?? this.elementIdentifier,
      outerHTML: outerHTML ?? this.outerHTML,
      innerHTML: innerHTML ?? this.innerHTML,
      id: id ?? this.id,
      classNames: classNames ?? this.classNames,
      attributes: attributes ?? this.attributes,
      tagName: tagName ?? this.tagName,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'elementIdentifier': elementIdentifier,
      'outerHTML': outerHTML,
      'innerHTML': innerHTML,
      'id': id,
      'classNames': classNames,
      'attributes': attributes,
      'tagName': tagName,
      'text': text,
    };
  }

  factory LootElement.fromMap(Map<String, dynamic> map) {
    return LootElement(
      elementIdentifier: map['elementIdentifier'] as String,
      outerHTML: map['outerHTML'] as String,
      innerHTML: map['innerHTML'] as String,
      id: map['id'] != null ? map['id'] as String : null,
      classNames: map['classNames'] != null
          ? List<String>.from((map['classNames'] as List<String>))
          : null,
      attributes: map['attributes'] != null
          ? Map<String, String>.from((map['attributes'] as Map<String, String>))
          : null,
      tagName: map['tagName'] as String,
      text: map['text'] != null ? map['text'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LootElement.fromJson(String source) =>
      LootElement.fromMap(json.decode(source) as Map<String, dynamic>);

  factory LootElement.fromElement(Element? el, String elementIdentifier) {
    return LootElement(
      elementIdentifier: elementIdentifier,
      id: el?.id,
      classNames: el?.className.split(" "),
      attributes: Map<String, String>.fromEntries(el?.attributes.entries.map(
              (entry) =>
                  MapEntry(entry.key.toString(), entry.value.toString())) ??
          {}),
      text: el?.text,
      outerHTML: el?.outerHtml ?? "",
      innerHTML: el?.innerHtml ?? "",
      tagName: el?.localName ?? "<>",
    );
  }

  Element toElement() => Element.html(outerHTML);

  @override
  String toString() {
    return 'LootElement(elementIdentifier: $elementIdentifier, outerHTML: $outerHTML, innerHTML: $innerHTML, id: $id, classNames: $classNames, attributes: $attributes, tagName: $tagName, text: $text)';
  }

  @override
  bool operator ==(covariant LootElement other) {
    if (identical(this, other)) return true;
    final collectionEquals = const DeepCollectionEquality().equals;

    return other.elementIdentifier == elementIdentifier &&
        other.outerHTML == outerHTML &&
        other.innerHTML == innerHTML &&
        other.id == id &&
        collectionEquals(other.classNames, classNames) &&
        collectionEquals(other.attributes, attributes) &&
        other.tagName == tagName &&
        other.text == text;
  }

  @override
  int get hashCode {
    return elementIdentifier.hashCode ^
        outerHTML.hashCode ^
        innerHTML.hashCode ^
        id.hashCode ^
        classNames.hashCode ^
        attributes.hashCode ^
        tagName.hashCode ^
        text.hashCode;
  }
}

extension LootElementExtensions on LootElement {
  ///
  /// Loot a single element with a selector and optionally give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', elementIdentifier: "bookTitle");
  ///```
  LootElement? loot(String selector, {String? elementIdentifier}) =>
      Looter.loot(outerHTML, selector, elementIdentifier: elementIdentifier);

  ///
  /// Loot multible elements with a selector and optionally give it a unique identifier to harvest.
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///  ```dart
  ///  List<LootElement?> result = await looter
  ///      .from("http://books.toscrape.com")
  ///      .lootAll('article.product_pod h3 a', elementIdentifier: "bookTitle");
  ///```
  ///
  List<LootElement?> lootAll(String selector, {String? elementIdentifier}) =>
      Looter.lootAll(outerHTML, selector, elementIdentifier: elementIdentifier);

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
  List<Map<String, dynamic>> loop(String parentSelector,
          Map<String, Map<String, String?>> childrenSelectors) =>
      Looter.loop(outerHTML, parentSelector, childrenSelectors);
}

extension FutureLootElementExtensions on Future<LootElement> {
  ///
  /// Loot a single element with a selector and optionally give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', elementIdentifier: "bookTitle");
  ///```
  Future<LootElement?> loot(String selector,
          {String? elementIdentifier}) async =>
      Looter.loot(await then((s) => s.outerHTML), selector,
          elementIdentifier: elementIdentifier);

  ///
  /// Loot multible elements with a selector and optionally give it a unique identifier to harvest.
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///  ```dart
  ///  List<LootElement?> result = await looter
  ///      .from("http://books.toscrape.com")
  ///      .lootAll('article.product_pod h3 a', elementIdentifier: "bookTitle");
  ///```
  ///
  Future<List<LootElement?>> lootAll(String selector,
          {String? elementIdentifier}) async =>
      Looter.lootAll(await then((s) => s.outerHTML), selector,
          elementIdentifier: elementIdentifier);

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
  Future<List<Map<String, dynamic>>> loop(String parentSelector,
          Map<String, Map<String, String?>> childrenSelectors) async =>
      Looter.loop(
          await then((s) => s.outerHTML), parentSelector, childrenSelectors);
}
