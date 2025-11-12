import Flutter
import UIKit

public class SwiftSecureApplicationPlugin: NSObject, FlutterPlugin {
    var secured = false;
    var secureView = UIVisualEffectView()
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
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        self.unlockApp()
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        if !secured { return }
        self.lockApp()
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        self.unlockApp()
    }
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
        case "secure":
        secured = true;
        result(nil)
    case "open":
        secured = false;
        self.unlockApp()
        result(nil)
    case "opacity":
        if let args = call.arguments as? Dictionary<String, Any>,
            let opacity = args["opacity"] as? NSNumber {
            self.opacity = opacity as! CGFloat
        }
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
    
    private func unlockApp() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.secureView.backgroundColor = UIColor(white: 1, alpha: 0.0)
            self.secureView.effect = nil
        }, completion: { [weak self] (_) in
            guard let self else { return }
            self.secureView.removeFromSuperview()
        })
    }
    
    private func lockApp() {
        let window = UIApplication.shared.windows.first
        
        if let window, !self.secureView.isDescendant(of: window) {
            self.secureView.frame = window.bounds
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.secureView.backgroundColor = UIColor(white: 1, alpha: self.opacity)
                self.secureView.effect = UIBlurEffect(style: .light)
            }
            window.addSubview(self.secureView)
            window.snapshotView(afterScreenUpdates: true)
        }
    }
}
