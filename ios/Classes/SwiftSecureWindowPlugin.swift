import Flutter
import UIKit

public class SwiftSecureWindowPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_window", binaryMessenger: registrar.messenger())
    let instance = SwiftSecureWindowPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func applicationWillResignActive(_ application: UIApplication) {
    print("test")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
