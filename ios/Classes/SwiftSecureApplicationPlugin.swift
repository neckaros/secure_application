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
                
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = window.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                blurEffectView.tag = 99699
                blurEffectView.backgroundColor = UIColor(white: 1, alpha: self.opacity)
                window.addSubview(blurEffectView)
                
                window.bringSubviewToFront(blurEffectView)
                
             
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
