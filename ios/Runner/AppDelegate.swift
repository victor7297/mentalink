import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/*import UIKit
import Flutter
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Registra los plugins generados para Flutter
    GeneratedPluginRegistrant.register(with: self)
    
    // Configura Google Sign-In con el Client ID de iOS
    GIDSignIn.sharedInstance().clientID = "44433966773-b5rv72vif48qrandudlq5fdhq1kjhai1.apps.googleusercontent.com"
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @available(iOS 9.0, *)
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Asegúrate de que Google Sign-In maneje la URL correctamente
    return GIDSignIn.sharedInstance().handle(url)
  }
}*/