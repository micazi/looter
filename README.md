# 🥇Looter🥇

A simple yet fully-featured web scraper for both static and dynamically generated web pages.

This package is built upon multible packages with easier integration/abstraction, Check them in the dependencies section.

[![pub package](https://img.shields.io/pub/v/looter)](https://pub.dartlang.org/packages/looter)

> This package is still in it's early stages. If there's an issue, Please feel free to head to the repo and [File a new issue](https://github.com/micazi/looter/issues).

## Getting Started

### 1. Depend on it

Add this to your package's pubspec.yaml file:

```
dependencies:
  looter: [latest version]
```

### 2. Install it

```
$ flutter pub get
```

### 3. Import it

```dart
import 'package:looter/looter.dart';
```

## As easy as a couple of lines to scrape a web page!

```dart
void main() async {
  //1. Initialize the Looter
  // and specify wheather you are going to use a static or dynamic crawler.
  // **Dynamic crawler uses puppeteer to initialize a headless browser.**
  Looter looter = await Looter.initialize();

  //2. Start Looting!
  LootElement result = await looter
      .from("http://books.toscrape.com")
      .loot('article.product_pod h3 a', "bookTitle");
}
```

---

## What can you do?

- ###### Loot one element with selector 1️⃣

```dart
  LootElement result = await looter
      .from("http://books.toscrape.com")
      .loot('article.product_pod h3 a',
      elementIdentifier: "bookTitle",
      );
```

- ###### Loot all elements with selector 🔗

```dart
  List<LootElement> result = await looter
      .from("http://books.toscrape.com")
      .lootAll('article.product_pod h3 a',
      elementIdentifier: "bookTitle",
      );
```

- ###### And my favorite, a Loot Loop ➰➰

```dart
  List<LootElement?> result =
      await looter.from("http://books.toscrape.com").loop(
    'ol.row li', // give the looper the shared parents selector..
 {
       'article.product_pod h3 a': {"bookTitle": 'text'},
       'div.image_container img': {"bookImage": 'src'},
       'div.product_price p.price_color': {'bookPrice': 'text'},
       'div.product_price instock availability': {'bookAvailability': 'text'},
     },
  );
```

## Checklist

- () Loots Chaining.
- () Exporting as an Excel.
- () Creating a web API from the LootResult with a configurable JSON.

## Contributing

Contributing is more than welcomed on any of my packages/plugins.
I will try to keep adding suggested features as i go.

<!-- **Current list of contributors:**
 -->

## Versioning

- **V1.0.0** - Initial Release.
- **V1.1.0** - Refactored lootLoop function for easier handling.

## Authors

**Michael Aziz** - [Github](https://github.com/micwaziz)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
