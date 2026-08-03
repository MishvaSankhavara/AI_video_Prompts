import Flutter
import UIKit
import GoogleMobileAds
import google_mobile_ads
import Security

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    if let controller = window?.rootViewController as? FlutterViewController {
      registerDeviceIdChannel(binaryMessenger: controller.binaryMessenger)
    }
    
    // Register the native ad factories on the default plugin registry
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self,
        factoryId: "grid_native",
        nativeAdFactory: NativeAdFactoryGrid()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self,
        factoryId: "fullscreen_native",
        nativeAdFactory: NativeAdFactoryFullScreen()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self,
        factoryId: "large_native",
        nativeAdFactory: NativeAdFactoryMedium() // Large uses Medium layout
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self,
        factoryId: "medium_native",
        nativeAdFactory: NativeAdFactoryMedium()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self,
        factoryId: "small_native",
        nativeAdFactory: NativeAdFactorySmall()
    )
    
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerDeviceIdChannel(binaryMessenger: engineBridge.applicationRegistrar.messenger())
    
    // Register the native ad factories on the implicit/background plugin registry
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        engineBridge.pluginRegistry,
        factoryId: "grid_native",
        nativeAdFactory: NativeAdFactoryGrid()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        engineBridge.pluginRegistry,
        factoryId: "fullscreen_native",
        nativeAdFactory: NativeAdFactoryFullScreen()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        engineBridge.pluginRegistry,
        factoryId: "large_native",
        nativeAdFactory: NativeAdFactoryMedium() // Large uses Medium layout
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        engineBridge.pluginRegistry,
        factoryId: "medium_native",
        nativeAdFactory: NativeAdFactoryMedium()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        engineBridge.pluginRegistry,
        factoryId: "small_native",
        nativeAdFactory: NativeAdFactorySmall()
    )
  }

  private func registerDeviceIdChannel(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "com.aivideoprompt/device_id", binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { (call, result) in
      if call.method == "getPersistentDeviceId" {
        if let cachedId = KeychainHelper.read() {
          result(cachedId)
        } else {
          let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
          KeychainHelper.save(deviceId)
          result(deviceId)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

class KeychainHelper {
  static let service = "com.aivideoprompt.deviceid"
  static let account = "persistent_device_id"
  
  static func save(_ value: String) {
    guard let data = value.data(using: .utf8) else { return }
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecValueData as String: data
    ]
    
    // Delete any existing item first
    SecItemDelete(query as CFDictionary)
    
    // Add new item
    SecItemAdd(query as CFDictionary, nil)
  }
  
  static func read() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status == errSecSuccess, let data = dataTypeRef as? Data {
      return String(data: data, encoding: .utf8)
    }
    
    return nil
  }
}
