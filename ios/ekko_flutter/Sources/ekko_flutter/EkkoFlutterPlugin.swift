import Ekko
import Flutter
import UIKit

public class EkkoFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bomunto.ekko", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(EkkoFlutterPlugin(), channel: channel)
  }

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
    default: result(FlutterMethodNotImplemented)
    }
  }
}
