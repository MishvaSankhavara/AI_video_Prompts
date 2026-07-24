//
//  NativeAdFactorySmall.swift
//  Runner
//
//  Created by Mac D on 28/06/25.
//

import GoogleMobileAds
import UIKit
import Flutter
import google_mobile_ads

// Extension to create UIColor from hex string
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}


class NativeAdFactorySmall: NSObject, FLTNativeAdFactory {

    private let appCardBackground = UIColor(hex: "#FBF4FA")
    private let appPrimary = UIColor(hex: "#5D1049")
    private let appSecondary = UIColor(hex: "#720D5D")
    private let appBorder = UIColor(hex: "#EBDCE7")
    private let appTextPrimary = UIColor(hex: "#4E0D3A")
    private let appTextMuted = UIColor(hex: "#86687F")

    func createNativeAd(_ nativeAd: NativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        print(">>> Swift NativeAdFactorySmall: createNativeAd called")
        return createCustomAdView(nativeAd)
    }
    
    private func createCustomAdView(_ nativeAd: NativeAd) -> NativeAdView {
        print(">>> Swift NativeAdFactorySmall: createCustomAdView started")
        let adView = NativeAdView()
        adView.backgroundColor = appCardBackground
        adView.layer.cornerRadius = 12
        adView.layer.borderColor = appBorder.cgColor
        adView.layer.borderWidth = 1.2
        adView.layer.shadowColor = UIColor.black.cgColor
        adView.layer.shadowOffset = CGSize(width: 0, height: 2)
        adView.layer.shadowRadius = 4
        adView.layer.shadowOpacity = 0.05
        
        // Create main stack view
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        // Top horizontal stack view: [Icon] [Text Stack] [Ad Badge]
        let topRowStack = UIStackView()
        topRowStack.axis = .horizontal
        topRowStack.spacing = 10
        topRowStack.alignment = .top
        topRowStack.translatesAutoresizingMaskIntoConstraints = false

        // Icon
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = .clear
        iconImageView.layer.cornerRadius = 8
        iconImageView.layer.masksToBounds = true
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        // Text Stack: [Headline] [Body]
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        // Headline
        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        headlineLabel.textColor = appTextPrimary
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false

        // Body
        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bodyLabel.textColor = appTextMuted
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .byTruncatingTail
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        textStack.addArrangedSubview(headlineLabel)
        textStack.addArrangedSubview(bodyLabel)

        // Ad label
        let adLabel = UILabel()
        adLabel.text = "Ad"
        adLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        adLabel.backgroundColor = appSecondary
        adLabel.textColor = .white
        adLabel.textAlignment = .center
        adLabel.layer.cornerRadius = 4
        adLabel.layer.masksToBounds = true
        adLabel.translatesAutoresizingMaskIntoConstraints = false

        // Modern CTA button
        let ctaButton = UIButton(type: .system)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        ctaButton.backgroundColor = appPrimary
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 8
        ctaButton.layer.masksToBounds = true
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false

        // Assemble layout (using UIStackViews to guarantee no overlaps)
        topRowStack.addArrangedSubview(iconImageView)
        topRowStack.addArrangedSubview(textStack)
        topRowStack.addArrangedSubview(adLabel)

        mainStackView.addArrangedSubview(topRowStack)
        mainStackView.addArrangedSubview(ctaButton)

        adView.addSubview(mainStackView)

        // Constraints
        NSLayoutConstraint.activate([
            // Main stack view constraints
            mainStackView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            mainStackView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            mainStackView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),

            // Icon size
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            // Ad badge size
            adLabel.widthAnchor.constraint(equalToConstant: 24),
            adLabel.heightAnchor.constraint(equalToConstant: 16),

            // CTA button height
            ctaButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Assign outlets
        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.iconView = iconImageView
        adView.callToActionView = ctaButton

        return configureAdView(adView, with: nativeAd)
    }
    
    private func configureAdView(_ adView: NativeAdView, with nativeAd: NativeAd) -> NativeAdView {
        print(">>> Swift NativeAdFactorySmall: configureAdView started")
        if let headlineView = adView.headlineView as? UILabel {
            headlineView.text = nativeAd.headline ?? "Discover Amazing App"
        }

        // Configure body
        if let bodyView = adView.bodyView as? UILabel {
            let bodyText = nativeAd.body ?? "Experience the best features and discover what makes this app special."
            bodyView.text = bodyText
        }

        // Configure icon with placeholder
        if let iconView = adView.iconView as? UIImageView {
            if let icon = nativeAd.icon {
                iconView.image = icon.image
                iconView.backgroundColor = UIColor.clear
            } else {
                // Create app icon placeholder (iOS 12 compatible)
                iconView.backgroundColor = appPrimary
                iconView.layer.cornerRadius = 12
                
                // Create a simple app icon placeholder using text
                let iconLabel = UILabel()
                iconLabel.text = "📱"
                iconLabel.font = UIFont.systemFont(ofSize: 24)
                iconLabel.textAlignment = .center
                iconLabel.translatesAutoresizingMaskIntoConstraints = false
                iconView.addSubview(iconLabel)
                
                NSLayoutConstraint.activate([
                    iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
                    iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
                ])
                
            }
        }

        // Configure Call to Action with dynamic text
        if let ctaView = adView.callToActionView as? UIButton {
            let ctaText = nativeAd.callToAction ?? "Install Now"
            ctaView.setTitle(ctaText, for: .normal)
            ctaView.isUserInteractionEnabled = false
            
            // Add subtle animation
            ctaView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseOut], animations: {
                ctaView.transform = CGAffineTransform.identity
            })
            
        }

        // Set the native ad
        adView.nativeAd = nativeAd
        
        // Add subtle entrance animation
        adView.alpha = 0
        adView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
            adView.alpha = 1
            adView.transform = CGAffineTransform.identity
        })
        
        return adView
    }
}

// MARK: - Alternative Compact Layout
extension NativeAdFactorySmall {
    
    // Alternative compact horizontal layout (iOS 12 compatible)
    private func createCompactAdView(_ nativeAd: NativeAd) -> NativeAdView {
        let adView = NativeAdView()
        adView.backgroundColor = appCardBackground
        adView.layer.cornerRadius = 10
        adView.layer.borderWidth = 1.2
        adView.layer.borderColor = appBorder.cgColor
        
        // Create horizontal stack
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 8
        iconView.layer.masksToBounds = true
        iconView.backgroundColor = .clear
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Text container
        let textContainer = UIStackView()
        textContainer.axis = .vertical
        textContainer.spacing = 2
        textContainer.alignment = .leading
        
        let headline = UILabel()
        headline.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        headline.textColor = appTextPrimary
        headline.numberOfLines = 1
        
        let body = UILabel()
        body.font = UIFont.systemFont(ofSize: 12)
        body.textColor = appTextMuted
        body.numberOfLines = 1
        
        textContainer.addArrangedSubview(headline)
        textContainer.addArrangedSubview(body)
        
        // CTA button
        let ctaButton = UIButton(type: .system)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        ctaButton.backgroundColor = appPrimary
        ctaButton.setTitleColor(.white, for: .normal)

        ctaButton.layer.cornerRadius = 6
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(textContainer)
        stackView.addArrangedSubview(ctaButton)
        
        adView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -8),
            
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            ctaButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        adView.headlineView = headline
        adView.bodyView = body
        adView.iconView = iconView
        adView.callToActionView = ctaButton
        
        return configureAdView(adView, with: nativeAd)
    }
}
