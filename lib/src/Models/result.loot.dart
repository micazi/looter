// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

import '../looter_base.dart';

import 'element.loot.dart';

class LootResult {
  int status;
  Map<String, String> headers;
  dynamic content;
  LootResult({
    required this.status,
    required this.headers,
    required this.content,
  });

  LootResult copyWith({
    int? status,
    Map<String, String>? headers,
    dynamic? content,
  }) {
    return LootResult(
      status: status ?? this.status,
      headers: headers ?? this.headers,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'headers': headers,
      'content': content,
    };
  }

  factory LootResult.fromMap(Map<String, dynamic> map) {
    return LootResult(
      status: map['status'] as int,
      headers: Map<String, String>.from(
        (map['headers'] as Map<String, String>),
      ),
      content: map['content'] as dynamic,
    );
  }

  String toJson() => json.encode(toMap());

  factory LootResult.fromJson(String source) =>
      LootResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'LootResult(status: $status, headers: $headers, content: $content)';

  @override
  bool operator ==(covariant LootResult other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.status == status &&
        mapEquals(other.headers, headers) &&
        other.content == content;
  }

  @override
  int get hashCode => status.hashCode ^ headers.hashCode ^ content.hashCode;
}

extension LootResultExtensions on LootResult {
  ///
  /// Loot a single element with a selector and give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  LootElement? loot(String selector, String elementIdentifier) =>
      Looter.loot(content, selector, elementIdentifier);

  ///
  /// Loot multible elements with a selector and give it a unique identifier to harvest.
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///  ```dart
  ///  List<LootElement?> result = await looter
  ///      .from("http://books.toscrape.com")
  ///      .lootAll('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  List<LootElement?> lootAll(String selector, String elementIdentifier) =>
      Looter.lootAll(
          this is String ? this : content, selector, elementIdentifier);

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
      Looter.lootLoop(content, parentSelector, childrenSelectors);
}

extension FutureLootResultExtensions on Future<LootResult> {
  ///
  /// Loot a single element with a selector and give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  Future<LootElement?> loot(String selector, String elementIdentifier) async =>
      Looter.loot(
          await then((value) => value.content), selector, elementIdentifier);

  ///
  /// Loot multible elements with a selector and give it a unique identifier to harvest.
  /// Returns [List<LootElement?>] with identifier: identifier#xx.
  ///  ```dart
  ///  List<LootElement?> result = await looter
  ///      .from("http://books.toscrape.com")
  ///      .lootAll('article.product_pod h3 a', "bookTitle");
  ///```
  ///
  Future<List<LootElement?>> lootAll(
          String selector, String elementIdentifier) async =>
      Looter.lootAll(
          await then((value) => value.content), selector, elementIdentifier);

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
      Looter.lootLoop(await then((value) => value.content), parentSelector,
          childrenSelectors);
}
