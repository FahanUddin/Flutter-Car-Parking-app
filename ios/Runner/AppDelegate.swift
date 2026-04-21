import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDp7ifSGv8j-uXCTAMyDTN3DNDuey2T0Xo")//<!--AIzaSyAnRrNGZ4oRS8nSX3WxSKN9BI_fHgrDGFQ AIzaSyDp7ifSGv8j-uXCTAMyDTN3DNDuey2T0Xo-->
    //[GMSServices provideAPIKey:"AIzaSyDp7ifSGv8j-uXCTAMyDTN3DNDuey2T0Xo"]
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  if (@available(iOS 10.0, *)) {
  [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
}
}
