import Flutter
import UIKit

public class SwiftSecureWindowPlugin: NSObject, FlutterPlugin {
    var secured = false;
    var opacity: CGFloat = 0.2;
    internal let registrar: FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
      super.init()
      registrar.addApplicationDelegate(self)
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_window", binaryMessenger: registrar.messenger())
    let instance = SwiftSecureWindowPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func applicationWillResignActive(_ application: UIApplication) {
    if ( secured ) {
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                   return w.isHidden == false
        }).first {
            let view = UIView(frame: window.frame)
            view.tag = 99699
            // 1
            view.backgroundColor = UIColor(white: 1, alpha: self.opacity)
            // 2
            let blurEffect = UIBlurEffect(style: .extraLight)
            // 3
            let blurView = UIVisualEffectView(effect: blurEffect)
            // 4
            blurView.frame = view.bounds
            view.addSubview(blurView)
            window.addSubview(view)
            window.bringSubviewToFront(view)
        }
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "secure") {
        secured = true;
        if let args = call.arguments as? Dictionary<String, Any>,
        let opacity = args["opacity"] as? NSNumber {
            self.opacity = opacity as! CGFloat
        }
    } else if (call.method == "open") {
        secured = false;
    } else if (call.method == "unlock") {
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                   return w.isHidden == false
        }).first, let view = window.viewWithTag(99699) {
            view.removeFromSuperview()
        }
    }
  }
}
