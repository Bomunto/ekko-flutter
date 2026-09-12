import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The three calls. Everything visible comes from the ekko dashboard.
class Ekko {
  static const MethodChannel _channel = MethodChannel('bomunto.ekko');

  /// Call once, before `runApp`. [teamId] is only read on iOS (App Attest);
  /// [baseUrl] is for development builds against a local API.
  static Future<void> configure({required String publicKey, String? teamId, String? baseUrl}) {
    _channel.setMethodCallHandler(_fromNative);
    return _channel.invokeMethod('configure', {'publicKey': publicKey, 'teamId': teamId, 'baseUrl': baseUrl});
  }

  static Future<void> present() => _channel.invokeMethod('present');

  static Future<void> identifyTester(String token) => _channel.invokeMethod('identifyTester', {'token': token});

  /// Feeds an invitation link. Returns whether ekko handled it.
  static Future<bool> handle(Uri uri) async =>
      (await _channel.invokeMethod<bool>('handle', {'url': uri.toString()})) ?? false;

  /// The native SDK asks Flutter for the screenshot: Flutter paints in a
  /// layer the platform cannot read back, but its own render tree can.
  static Future<dynamic> _fromNative(MethodCall call) async {
    if (call.method != 'captureScreen') return null;
    final views = WidgetsBinding.instance.renderViews;
    if (views.isEmpty) return null;
    final view = views.first;
    // The getter is annotated protected for subclasses; reading the root
    // view's layer to rasterise it is what integration tests do too.
    // ignore: invalid_use_of_protected_member
    final layer = view.layer;
    if (layer is! OffsetLayer) return null;
    final image = await layer.toImage(view.paintBounds);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes?.buffer.asUint8List();
  }
}
