// ignore_for_file: no_leading_underscores_for_local_identifiers, depend_on_referenced_packages
import 'package:logging/logging.dart';
import 'package:puppeteer/plugin.dart';
import 'package:puppeteer/puppeteer.dart';

import 'chrome_downloader.dart';
export 'package:puppeteer/puppeteer.dart';

Future<Browser> initializeBrowser({
  bool headless = true,
  DeviceViewport defaultViewport = LaunchOptions.viewportNotSpecified,
  Map<String, String>? environmentVariables,
  bool warm = true,
  Duration timeout = const Duration(seconds: 30),
  bool debugLog = true,
  List<String>? arguments,
}) async {
  Logger('puppeteer.launcher').level = debugLog ? Level.INFO : Level.OFF;
  //
  await download_chrome();
  //
  Browser _browser = await puppeteer.launch(
    timeout: timeout,
    headless: headless,
    defaultViewport: defaultViewport,
    environment: environmentVariables,
    args: arguments,
  );
  if (warm) {
    await _browser.newPage().then((_page) async {
      await _page.goto('https://google.com');
      //
      await _page.close();
    });
  }
  //
  return _browser;
}
