import 'package:flutter/services.dart';

/// The three calls. Everything visible comes from the ekko dashboard.
class Ekko {
  static const MethodChannel _channel = MethodChannel('bomunto.ekko');

  /// Call once, before `runApp`. [teamId] is only read on iOS (App Attest);
  /// [baseUrl] is for development builds against a local API.
  static Future<void> configure({required String publicKey, String? teamId, String? baseUrl}) =>
      _channel.invokeMethod('configure', {'publicKey': publicKey, 'teamId': teamId, 'baseUrl': baseUrl});

  static Future<void> present() => _channel.invokeMethod('present');

  static Future<void> identifyTester(String token) => _channel.invokeMethod('identifyTester', {'token': token});

  /// Feeds an invitation link. Returns whether ekko handled it.
  static Future<bool> handle(Uri uri) async =>
      (await _channel.invokeMethod<bool>('handle', {'url': uri.toString()})) ?? false;
}
