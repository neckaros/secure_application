import Flutter
import UIKit

public class SwiftSecureApplicationPlugin: NSObject, FlutterPlugin {
    var secured = false;
    var opacity: CGFloat = 0.2;
    
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
            if let existingView = window.viewWithTag(99699) {
                window.bringSubviewToFront(existingView)
                return
            } else {
                let imageView = UIImageView.init(frame: window.bounds)
                imageView.tag = 99699
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
        }).first, let view = window.viewWithTag(99699) {
            UIView.animate(withDuration: 0.5, animations: {
                view.alpha = 0.0
            }, completion: { finished in
            view.removeFromSuperview()
            })
        }
    }
  }
}
