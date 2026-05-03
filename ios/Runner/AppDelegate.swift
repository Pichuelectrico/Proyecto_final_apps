import Flutter
import UIKit
import Foundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "vibeshare_widget", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        guard call.method == "saveLatestImage" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "invalid_args", message: "Missing args", details: nil))
          return
        }
        let defaults = UserDefaults(suiteName: "group.com.example.flutterBddFirebaseEjm4")
        if let typed = args["imageData"] as? FlutterStandardTypedData {
          defaults?.set(typed.data, forKey: "latest_image_data")
        }
        defaults?.set(args["caption"] as? String ?? "", forKey: "latest_image_caption")
        defaults?.set(args["senderId"] as? String ?? "", forKey: "latest_image_sender")
        defaults?.set(args["senderName"] as? String ?? "", forKey: "latest_image_sender_name")
        result(true)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
