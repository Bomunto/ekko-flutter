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

  /// Names the screen the tester is on. It lands in the report's timeline and
  /// in « Pour reproduire ».
  static Future<void> screen(String name) => _channel.invokeMethod('screen', {'name': name});

  /// Adds a line to the report's console. [level] is one of
  /// `log | info | warn | error | debug`.
  static Future<void> log(String message, {String level = 'info'}) =>
      _channel.invokeMethod('log', {'message': message, 'level': level});

  /// Adds a call to the report's network log. Never send a body or a header:
  /// only the method, the URL, the status and the duration travel.
  static Future<void> recordRequest({
    required String method,
    required String url,
    int? status,
    int? durationMs,
  }) =>
      _channel.invokeMethod('recordRequest', {
        'method': method,
        'url': url,
        'status': status,
        'durationMs': durationMs,
      });

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

/// Names every screen for ekko, from the app's own routes. Add it to
/// `MaterialApp.navigatorObservers` and name the routes:
///
/// ```dart
/// MaterialApp(navigatorObservers: [EkkoNavigatorObserver()], ...)
/// ```
class EkkoNavigatorObserver extends NavigatorObserver {
  /// Creates the observer.
  EkkoNavigatorObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _record(route);

  /// After a pop the screen underneath is the one the tester sees.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _record(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _record(newRoute);

  static void _record(Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name;
    Ekko.screen(name != null && name.isNotEmpty ? name : route.runtimeType.toString());
  }
}
