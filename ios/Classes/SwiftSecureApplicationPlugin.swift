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
            if let existingView = window.viewWithTag(99699), let existingBlurrView = window.viewWithTag(99698) {
                window.bringSubviewToFront(existingView)
                window.bringSubviewToFront(existingBlurrView)
                return
            } else {
                let colorView = UIView(frame: window.bounds);
                colorView.tag = 99699
                colorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                colorView.backgroundColor = UIColor(white: 1, alpha: opacity)
                
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = window.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                blurEffectView.tag = 99698

                window.addSubview(colorView)
                window.addSubview(blurEffectView)
                
                window.bringSubviewToFront(colorView)
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
    }  else if (call.method == "opacity") {
            if let args = call.arguments as? Dictionary<String, Any>,
                  let opacity = args["opacity"] as? NSNumber {
               self.opacity = opacity as! CGFloat
           }
    } else if (call.method == "unlock") {
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                   return w.isHidden == false
        }).first, let view = window.viewWithTag(99699), let blurrView = window.viewWithTag(99698) {
            view.removeFromSuperview()
            blurrView.removeFromSuperview()
        }
    }
  }
}
