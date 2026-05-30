import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=',
  );

  @override
  Future<ByteData> load(String key) async {
    return ByteData.view(_transparentPng.buffer);
  }
}

Widget wrapWithMaterial(Widget child) {
  return DefaultAssetBundle(
    bundle: TestAssetBundle(),
    child: MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

Widget wrapAsPage(Widget child) {
  return DefaultAssetBundle(
    bundle: TestAssetBundle(),
    child: MaterialApp(home: child),
  );
}
