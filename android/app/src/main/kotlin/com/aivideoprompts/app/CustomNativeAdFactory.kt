package com.example.aivideoprompts

import android.content.Context
import android.view.LayoutInflater
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

class CustomNativeAdFactory(private val context: Context, private val layoutResId: Int) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context).inflate(layoutResId, null) as NativeAdView

        // Map layout views to NativeAdView components safely
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val callToActionView = adView.findViewById<TextView>(R.id.ad_call_to_action)
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        
        val iconView = adView.findViewById<android.widget.ImageView>(R.id.ad_app_icon)
        val advertiserView = adView.findViewById<TextView>(R.id.ad_label)

        // Bind Headline
        if (headlineView != null) {
            adView.headlineView = headlineView
            headlineView.text = nativeAd.headline
        }

        // Bind Body
        if (bodyView != null) {
            adView.bodyView = bodyView
            if (nativeAd.body == null) {
                bodyView.visibility = android.view.View.INVISIBLE
            } else {
                bodyView.visibility = android.view.View.VISIBLE
                bodyView.text = nativeAd.body
            }
        }

        // Bind Call To Action
        if (callToActionView != null) {
            adView.callToActionView = callToActionView
            if (nativeAd.callToAction == null) {
                callToActionView.visibility = android.view.View.INVISIBLE
            } else {
                callToActionView.visibility = android.view.View.VISIBLE
                callToActionView.text = nativeAd.callToAction
            }
        }

        // Bind Media View
        if (mediaView != null) {
            adView.mediaView = mediaView
        }

        // Bind Icon
        if (iconView != null) {
            adView.iconView = iconView
            if (nativeAd.icon == null) {
                iconView.visibility = android.view.View.GONE
            } else {
                iconView.setImageDrawable(nativeAd.icon?.drawable)
                iconView.visibility = android.view.View.VISIBLE
            }
        }

        // Bind Advertiser / Label
        if (advertiserView != null) {
            adView.advertiserView = advertiserView
            if (nativeAd.advertiser == null) {
                advertiserView.visibility = android.view.View.GONE
            } else {
                advertiserView.text = nativeAd.advertiser
                advertiserView.visibility = android.view.View.VISIBLE
            }
        }

        // Tell the Google Mobile Ads SDK that you have finished populating your native ad view
        adView.setNativeAd(nativeAd)

        return adView
    }
}
