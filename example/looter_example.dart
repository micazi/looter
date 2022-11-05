import 'package:looter/looter.dart';

void main() async {
  //1. Initialize the Looter
  // and specify wheather you are going to use a static or dynamic crawler.
  // the first time you use a dynamic crawler it will take some time to download the chrome binaries, please be patient.
  // for more info see "https://pub.dev/packages/puppeteer".
  Looter looter =
      await Looter.initialize(crawlingMethod: CrawlingMethod.dynamicCrawler);
  //
  //2. Start Looting!
  List<LootElement?> result = await looter
      .from(
    "http://books.toscrape.com",
    waitUntil: Until.domContentLoaded,
    timeout: Duration(
      seconds: 20,
    ),
  )
      .lootLoop(
    'ol.row li', // give the looper the shared parents selector..
    {
      // give it a map of identifiers (to identify later from the list of elements
      // as 'identifier#parentnumber) and a child selector.'
      "bookTitle": "article.product_pod h3 a",
      "bookPrice": "div.product_price p.price_color",
      "bookAvailability": "div.product_price instock availability",
    },
  );
  // filter the list by element identifiers like this:
  LootElement? elementIWant = result
      .where(
        (e) => e?.elementIdentifier == "bookTitle#5",
      )
      .single;
}
