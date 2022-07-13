import Flutter
import UIKit

public class SwiftSecureApplicationPlugin: NSObject, FlutterPlugin {
    var secured = false;
    var opacity: CGFloat = 0.2;
    var useLaunchImage: Bool = false;
    var backgroundColor: UIColor = UIColor.white;

    var backgroundTask: UIBackgroundTaskIdentifier!

    let IMAGE_VIEW_TAG = 99697;
    let BLUR_VIEW_TAG = 99698;
    let COLOR_VIEW_TAG = 99699;

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
            if (!useLaunchImage) {
                if let existingColorView = window.viewWithTag(COLOR_VIEW_TAG) {
                    window.bringSubviewToFront(existingColorView)
                } else {
                    let colorView = UIView(frame: window.bounds);
                    colorView.tag = COLOR_VIEW_TAG
                    colorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    colorView.backgroundColor = backgroundColor.withAlphaComponent(opacity)
                    window.addSubview(colorView)
                    window.bringSubviewToFront(colorView)
                }
            }

            if let existingBlurrView = window.viewWithTag(BLUR_VIEW_TAG) {
                window.bringSubviewToFront(existingBlurrView)
            } else {
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = window.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blurEffectView.tag = BLUR_VIEW_TAG
                window.addSubview(blurEffectView)
                window.bringSubviewToFront(blurEffectView)
            }

            if (useLaunchImage) {
                if let existingImageView = window.viewWithTag(IMAGE_VIEW_TAG) {
                    window.bringSubviewToFront(existingImageView)
                    return
                } else {
                    let imageView = UIImageView.init(frame: window.bounds)
                    imageView.tag = IMAGE_VIEW_TAG
                    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    imageView.backgroundColor = backgroundColor.withAlphaComponent(opacity)
                    imageView.clipsToBounds = true
                    imageView.contentMode = .center
                    imageView.image = UIImage(named: "LaunchImage")
                    imageView.isMultipleTouchEnabled = true
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    window.addSubview(imageView)
                    window.bringSubviewToFront(imageView)
                }
            }

            window.snapshotView(afterScreenUpdates: true)
            RunLoop.current.run(until: Date(timeIntervalSinceNow:0.5))
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

            if let backgroundColor = args["backgroundColor"] as? String {
                self.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            }
        }
    } else if (call.method == "open") {
        secured = false;
    } else if (call.method == "opacity") {
        if let args = call.arguments as? Dictionary<String, Any>,
              let opacity = args["opacity"] as? NSNumber {
           self.opacity = opacity as! CGFloat
       }
    } else if (call.method == "backgroundColor") {
        if let args = call.arguments as? Dictionary<String, Any>,
              let backgroundColor = args["backgroundColor"] as? String {
           self.backgroundColor = hexStringToUIColor(hex: backgroundColor)
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
            if let colorView = window.viewWithTag(COLOR_VIEW_TAG) {
                UIView.animate(withDuration: 0.4, animations: {
                    colorView.alpha = 0.0
                }, completion: { finished in
                    colorView.removeFromSuperview()
                })
            }

            if let imageView = window.viewWithTag(IMAGE_VIEW_TAG) {
                UIView.animate(withDuration: 0.4, animations: {
                    imageView.alpha = 0.0
                }, completion: { finished in
                    imageView.removeFromSuperview()
                })
            }

            if let blurrView = window.viewWithTag(BLUR_VIEW_TAG) {
                blurrView.removeFromSuperview()
            }
        }
    }
  }

  func hexStringToUIColor (hex:String) -> UIColor {
      var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

      if (cString.hasPrefix("#")) {
          cString.remove(at: cString.startIndex)
      }

      if ((cString.count) != 6) {
          return UIColor.gray
      }

      var rgbValue:UInt64 = 0
      Scanner(string: cString).scanHexInt64(&rgbValue)

      return UIColor(
          red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
          green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
          blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
          alpha: CGFloat(1.0)
      )
  }
}
