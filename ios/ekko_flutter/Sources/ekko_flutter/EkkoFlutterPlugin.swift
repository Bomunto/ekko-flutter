import Ekko
import Flutter
import UIKit

public class EkkoFlutterPlugin: NSObject, FlutterPlugin {
  @MainActor
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bomunto.ekko", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(EkkoFlutterPlugin(), channel: channel)
    // Flutter draws in a Metal layer UIKit cannot read: the screenshot comes
    // from Flutter's own render tree, through the channel.
    Ekko.captureProvider = { done in
      channel.invokeMethod("captureScreen", arguments: nil) { reply in
        if let bytes = reply as? FlutterStandardTypedData, let image = UIImage(data: bytes.data) {
          done(image)
        } else {
          done(nil)
        }
      }
    }
  }

  // Method-channel calls land on the platform thread, and the ekko SDK is
  // main-actor isolated.
  @MainActor
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "configure":
      guard let publicKey = args["publicKey"] as? String else { return result(FlutterError(code: "args", message: "publicKey manquante", details: nil)) }
      let teamId = args["teamId"] as? String ?? ""
      let baseURL = (args["baseUrl"] as? String).flatMap(URL.init(string:))
      Ekko.configure(publicKey: publicKey, teamId: teamId, baseURL: baseURL)
      result(nil)
    case "present": Ekko.present(); result(nil)
    case "identifyTester":
      if let token = args["token"] as? String { Ekko.identifyTester(token: token) }
      result(nil)
    case "handle":
      let handled = (args["url"] as? String).flatMap(URL.init(string:)).map(Ekko.handle(url:)) ?? false
      result(handled)
    case "screen":
      if let name = args["name"] as? String { Ekko.screen(name) }
      result(nil)
    case "log":
      if let message = args["message"] as? String {
        Ekko.log(message, level: args["level"] as? String ?? "info")
      }
      result(nil)
    case "recordRequest":
      guard let method = args["method"] as? String, let url = args["url"] as? String else { return result(nil) }
      Ekko.recordRequest(
        method: method,
        url: url,
        status: args["status"] as? Int,
        durationMs: args["durationMs"] as? Int
      )
      result(nil)
    default: result(FlutterMethodNotImplemented)
    }
  }
}
