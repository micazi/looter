// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:puppeteer/src/downloader.dart';

//
void main() async => download_chrome();

Future<void> download_chrome() async {
  if (!check_chrome()) {
    print("Downloading chrome, please wait...");
    RevisionInfo x = await downloadChrome(
      cachePath: null,
    );
    print("Chrome Downloaded Succsessfully. Revision ${x.revision}");
  }
}

//
const int _lastRevision = 1056772;
String cachePath = '.local-chromium';
//
bool check_chrome() {
  var revisionDirectory = Directory(p.join(cachePath, '$_lastRevision'));
  if (!revisionDirectory.existsSync() ||
      !File(getExecutablePath(revisionDirectory.path)).existsSync()) {
    return false;
  } else {
    return true;
  }
}
