import GoogleMobileAds
import UIKit
import Flutter
import google_mobile_ads

// Extension to create UIColor from hex string
// extension UIColor {
//     convenience init(hex: String) {
//         let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//         var int: UInt64 = 0
//         Scanner(string: hex).scanHexInt64(&int)
//         let a, r, g, b: UInt64
//         switch hex.count {
//         case 3: // RGB (12-bit)
//             (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//         case 6: // RGB (24-bit)
//             (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//         case 8: // ARGB (32-bit)
//             (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//         default:
//             (a, r, g, b) = (1, 1, 1, 0)
//         }
//         self.init(
//             red: Double(r) / 255,
//             green: Double(g) / 255,
//             blue:  Double(b) / 255,
//             alpha: Double(a) / 255


class NativeAdFactoryMedium: NSObject, FLTNativeAdFactory {

    private let appCardBackground = UIColor(hex: "#FBF4FA")
    private let appPrimary = UIColor(hex: "#5D1049")
    private let appSecondary = UIColor(hex: "#720D5D")
    private let appBorder = UIColor(hex: "#EBDCE7")
    private let appTextPrimary = UIColor(hex: "#4E0D3A")
    private let appTextMuted = UIColor(hex: "#86687F")

    func createNativeAd(_ nativeAd: NativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        print(">>> Swift NativeAdFactoryMedium: createNativeAd called")
        return createProgrammaticAdView(nativeAd)
    }
    private func createProgrammaticAdView(_ nativeAd: NativeAd) -> NativeAdView {
        print(">>> Swift NativeAdFactoryMedium: createProgrammaticAdView started")
        let adView = NativeAdView()
        adView.backgroundColor = appCardBackground
        adView.layer.cornerRadius = 12
        adView.layer.borderColor = appBorder.cgColor
        adView.layer.borderWidth = 1.2
        adView.layer.shadowColor = UIColor.black.cgColor
        adView.layer.shadowOffset = CGSize(width: 0, height: 2)
        adView.layer.shadowRadius = 4
        adView.layer.shadowOpacity = 0.05

        // Create ad label
        let adLabel = UILabel()
        adLabel.text = "Ad"
        adLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        adLabel.textColor = .white
        adLabel.backgroundColor = appSecondary
        adLabel.textAlignment = .center
        adLabel.layer.cornerRadius = 4
        adLabel.clipsToBounds = true
        adLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create main stack view
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 2
        mainStackView.backgroundColor = appCardBackground
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        // Top horizontal stack view: [Ad Badge] [Icon] [Headline]
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.spacing = 8
        topStackView.alignment = .center
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = UIColor.clear
        iconImageView.layer.cornerRadius = 4
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Headline
        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headlineLabel.textColor = appTextPrimary
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Media view
        let mediaView = MediaView()
        mediaView.backgroundColor = UIColor.clear
        mediaView.layer.cornerRadius = 8
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        
        // Body
        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        bodyLabel.textColor = appTextMuted
        bodyLabel.numberOfLines = 3
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // CTA button
        let ctaButton = UIButton(type: .system)
        ctaButton.backgroundColor = appPrimary
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        ctaButton.layer.cornerRadius = 8
        ctaButton.translatesAutoresizingMaskIntoConstraints = false

        // Assemble top section (arranged in UIStackView to guarantee NO overlaps)
        topStackView.addArrangedSubview(adLabel)
        topStackView.addArrangedSubview(iconImageView)
        topStackView.addArrangedSubview(headlineLabel)
        
        // Assemble main layout
        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(mediaView)
        mainStackView.addArrangedSubview(bodyLabel)
        mainStackView.addArrangedSubview(ctaButton)
        
        adView.addSubview(mainStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Main stack view constraints
            mainStackView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            mainStackView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            mainStackView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),

            // Ad label constraints
            adLabel.widthAnchor.constraint(equalToConstant: 24),
            adLabel.heightAnchor.constraint(equalToConstant: 16),

            // Icon constraints
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Media view constraints
            mediaView.heightAnchor.constraint(equalToConstant: 120),
            
            // CTA button constraints
            ctaButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Assign outlets
        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.iconView = iconImageView
        adView.callToActionView = ctaButton
        adView.mediaView = mediaView
        
        return configureAdView(adView, with: nativeAd)
    }
    
    private func configureAdView(_ adView: NativeAdView, with nativeAd: NativeAd) -> NativeAdView {
        print(">>> Swift NativeAdFactoryMedium: configureAdView started")
        if let headlineView = adView.headlineView as? UILabel {
            headlineView.text = nativeAd.headline ?? "No headline"
        }
        
        if let bodyView = adView.bodyView as? UILabel {
            bodyView.text = nativeAd.body ?? "No description available"
        }
        
        if let iconView = adView.iconView as? UIImageView {
            iconView.image = nativeAd.icon?.image
        }
        
        if let ctaView = adView.callToActionView as? UIButton {
            ctaView.setTitle(nativeAd.callToAction ?? "Learn More", for: .normal)
            ctaView.isUserInteractionEnabled = false
        }
        
        if let mediaView = adView.mediaView {
            mediaView.mediaContent = nativeAd.mediaContent
        }
        
        adView.nativeAd = nativeAd

        // Add subtle entrance animation
//         adView.backgroundColor = UIColor.white

        return adView
    }
}
