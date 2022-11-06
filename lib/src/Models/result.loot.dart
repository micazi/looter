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
  /// Loot a single element with a selector and optionally give it a unique identifier to harvest.
  /// Returns a [LootElement].
  ///```dart
  /// LootElement result = await looter
  ///    .from("http://books.toscrape.com")
  ///    .loot('article.product_pod h3 a', elementIdentifier: "bookTitle");
  ///```
  LootElement? loot(String selector, {String? elementIdentifier}) =>
      Looter.loot(content, selector, elementIdentifier: elementIdentifier);

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
      Looter.lootAll(this is String ? this : content, selector,
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
  List<Map<String, dynamic>> loop(String parentSelector,
          Map<String, Map<String, String?>> childrenSelectors) =>
      Looter.loop(content, parentSelector, childrenSelectors);
}

extension FutureLootResultExtensions on Future<LootResult> {
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
      Looter.loot(await then((value) => value.content), selector,
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
      Looter.lootAll(await then((value) => value.content), selector,
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
      Looter.loop(await then((value) => value.content), parentSelector,
          childrenSelectors);
}
