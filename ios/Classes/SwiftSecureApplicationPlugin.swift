import Flutter
import UIKit

public class SwiftSecureApplicationPlugin: NSObject, FlutterPlugin {
    var secured = false;
    var opacity: CGFloat = 0.2;
    var useLaunchImage: Bool = false;

    var backgroundTask: UIBackgroundTaskIdentifier!
    
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
        self.registerBackgroundTask()
        UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                   return w.isHidden == false
        }).first {
            if (useLaunchImage) {
                if let existingView = window.viewWithTag(99697) {
                    window.bringSubviewToFront(existingView)
                    return
                } else {
                    let imageView = UIImageView.init(frame: window.bounds)
                    imageView.tag = 99697
                    imageView.backgroundColor = UIColor.black
                    imageView.tintColor = UIColor.white
                    imageView.clipsToBounds = true
                    imageView.contentMode = .center
                    imageView.image = UIImage(named: "LaunchImage")
                    imageView.isMultipleTouchEnabled = true
                    imageView.translatesAutoresizingMaskIntoConstraints = false

                    window.addSubview(imageView)
                    window.bringSubviewToFront(imageView)

                    window.snapshotView(afterScreenUpdates: true)
                    RunLoop.current.run(until: Date(timeIntervalSinceNow:0.5))
                }
            } else {
                if let existingView = window.viewWithTag(99699), let existingBlurrView = window.viewWithTag(99698) {
                    window.bringSubviewToFront(existingView)
                    window.bringSubviewToFront(existingBlurrView)
                    return
                } else {
                    let colorView = UIView(frame: window.bounds);
                    colorView.tag = 99699
                    colorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    colorView.backgroundColor = UIColor(white: 1, alpha: opacity)
                    window.addSubview(colorView)
                    window.bringSubviewToFront(colorView)

                    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.frame = window.bounds
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                    blurEffectView.tag = 99698

                    window.addSubview(blurEffectView)
                    window.bringSubviewToFront(blurEffectView)
                    window.snapshotView(afterScreenUpdates: true)
                    RunLoop.current.run(until: Date(timeIntervalSinceNow:0.5))
                }
            }
        }
    self.endBackgroundTask()
    }
  }
   func registerBackgroundTask() {
        self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(self.backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }

    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "secure") {
        secured = true;
        if let args = call.arguments as? Dictionary<String, Any> {
            if let opacity = args["opacity"] as? NSNumber {
                self.opacity = opacity as! CGFloat
            }

            if let useLaunchImage = args["useLaunchImage"] as? Bool {
                 self.useLaunchImage = useLaunchImage
             }
        }
    } else if (call.method == "open") {
        secured = false;
    } else if (call.method == "opacity") {
        if let args = call.arguments as? Dictionary<String, Any>,
              let opacity = args["opacity"] as? NSNumber {
           self.opacity = opacity as! CGFloat
       }
    } else if (call.method == "useLaunchImage") {
        if let args = call.arguments as? Dictionary<String, Any>,
              let useLaunchImage = args["useLaunchImage"] as? Bool {
           self.useLaunchImage = useLaunchImage
       }
    } else if (call.method == "unlock") {
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                   return w.isHidden == false
        }).first {
            if let colorView = window.viewWithTag(99699), let blurrView = window.viewWithTag(99698) {
                UIView.animate(withDuration: 0.5, animations: {
                    colorView.alpha = 0.0
                }, completion: { finished in
                    colorView.removeFromSuperview()
                    blurrView.removeFromSuperview()
                })
            }

            if let imageView = window.viewWithTag(99697) {
                UIView.animate(withDuration: 0.3, animations: {
                    imageView.alpha = 0.0
                }, completion: { finished in
                    imageView.removeFromSuperview()
                })
            }
        }
    }
  }
}
