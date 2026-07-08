package com.example.aivideoprompts

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the 4 custom Native Ad layouts
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "grid_ad_factory",
            CustomNativeAdFactory(context, R.layout.grid_view_native_ad)
        )

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "fullscreen_ad_factory",
            CustomNativeAdFactory(context, R.layout.layout_native_ads_fullscreen)
        )

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "large_ad_factory",
            CustomNativeAdFactory(context, R.layout.layout_native_ads_large)
        )

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "medium_ad_factory",
            CustomNativeAdFactory(context, R.layout.layout_native_ads_medium)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        
        // Unregister to prevent memory leaks
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "grid_ad_factory")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "fullscreen_ad_factory")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "large_ad_factory")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "medium_ad_factory")
    }
}
