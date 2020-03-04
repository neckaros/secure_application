import Flutter
import UIKit

public class SwiftSecureApplicationPlugin: NSObject, FlutterPlugin {
    var secured = false;
    var opacity: CGFloat = 0.2;
    internal let registrar: FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
      super.init()
      registrar.addApplicationDelegate(self)
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_application", binaryMessenger: registrar.messenger())
    let instance = SwiftSecureApplicationPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func applicationWillResignActive(_ application: UIApplication) {
    if ( secured ) {
        UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                   return w.isHidden == false
        }).first {
            if let existingView = window.viewWithTag(99699) {
                window.bringSubviewToFront(existingView)
                return
            } else {
                let view = UIView(frame: window.frame)
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
    RunLoop.current.run(until: Date(timeIntervalSinceNow:0.5))
  }
    public func applicationDidEnterBackground(_ application: UIApplication) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow:0.5))
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
