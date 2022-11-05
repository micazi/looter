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
  List<LootElement> children;
  LootElement({
    required this.elementIdentifier,
    required this.outerHTML,
    required this.innerHTML,
    this.id,
    this.classNames,
    this.attributes,
    required this.tagName,
    this.text,
    required this.children,
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
    List<LootElement>? children,
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
      children: children ?? this.children,
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
      'children': children.map((x) => x.toMap()).toList(),
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
      children: List<LootElement>.from(
        (map['children'] as List<int>).map<LootElement>(
          (x) => LootElement.fromMap(x as Map<String, dynamic>),
        ),
      ),
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
      children: [],
    );
  }

  Element toElement() => Element.html(outerHTML);

  @override
  String toString() {
    return 'LootElement(elementIdentifier: $elementIdentifier, outerHTML: $outerHTML, innerHTML: $innerHTML, id: $id, classNames: $classNames, attributes: $attributes, tagName: $tagName, text: $text, children: $children)';
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
        other.text == text &&
        collectionEquals(other.children, children);
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
        text.hashCode ^
        children.hashCode;
  }
}

extension LootElementExtensions on LootElement {
  ///
  /// Loot a single element with a selector and give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  LootElement loot(String selector, String elementIdentifier) =>
      Looter.loot(outerHTML, selector, elementIdentifier);

  ///
  /// Loot multible elements with a selector and give it a unique identifier to harvest.
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///  ```dart
  ///  List<LootElement?> result = await looter
  ///      .from("http://books.toscrape.com")
  ///      .lootAll('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  List<LootElement> lootAll(String selector, String elementIdentifier) =>
      Looter.lootAll(outerHTML, selector, elementIdentifier);

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
  List<LootElement?> lootLoop(
          String parentSelector, Map<String, String> childrenSelectors) =>
      Looter.lootLoop(outerHTML, parentSelector, childrenSelectors);
}

extension FutureLootElementExtensions on Future<LootElement> {
  ///
  /// Loot a single element with a selector and give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  Future<LootElement> loot(String selector, String elementIdentifier) async =>
      Looter.loot(await then((s) => s.outerHTML), selector, elementIdentifier);

  ///
  /// Loot multible elements with a selector and give it a unique identifier to harvest.
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///  ```dart
  ///  List<LootElement?> result = await looter
  ///      .from("http://books.toscrape.com")
  ///      .lootAll('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  Future<List<LootElement>> lootAll(
          String selector, String elementIdentifier) async =>
      Looter.lootAll(
          await then((s) => s.outerHTML), selector, elementIdentifier);

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
  Future<List<LootElement?>> lootLoop(
          String parentSelector, Map<String, String> childrenSelectors) async =>
      Looter.lootLoop(
          await then((s) => s.outerHTML), parentSelector, childrenSelectors);
}
