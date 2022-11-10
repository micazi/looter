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
  List<Map<String, dynamic>> result =
      await looter.from("http://books.toscrape.com").loop(
    'ol.row li', // give the looper the shared parents selector..
    {
      'article.product_pod h3 a': {"bookTitle": 'text'},
      'div.image_container img': {"bookImage": 'src'},
      'div.product_price p.price_color': {'bookPrice': 'text'},
      'div.product_price instock availability': {'bookAvailability': 'text'},
      // and if you want to loot multible children, use the array modifier! 'array:text', 'array:src', etc..
    },
  );
  print(result.toString());
}
