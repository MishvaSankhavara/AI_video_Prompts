import Flutter
import UIKit
import GoogleMobileAds
import google_mobile_ads

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
}
