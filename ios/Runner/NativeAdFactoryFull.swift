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
//         )
//     }
// }






class NativeAdFactoryFullScreen: NSObject, FLTNativeAdFactory {

    private let appCardBackground = UIColor(hex: "#FBF4FA")
    private let appPrimary = UIColor(hex: "#5D1049")
    private let appSecondary = UIColor(hex: "#720D5D")
    private let appBorder = UIColor(hex: "#EBDCE7")
    private let appTextPrimary = UIColor(hex: "#4E0D3A")
    private let appTextMuted = UIColor(hex: "#86687F")

    func createNativeAd(_ nativeAd: NativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        print(">>> Swift NativeAdFactoryFullScreen: createNativeAd called")
        return createFullScreenAdView(nativeAd)
    }

    private func createFullScreenAdView(_ nativeAd: NativeAd) -> NativeAdView {
        print(">>> Swift NativeAdFactoryFullScreen: createFullScreenAdView started")
        let adView = NativeAdView()
        adView.backgroundColor = appCardBackground
        
        // Create scroll view for full screen content
        let scrollView = UIScrollView()
        scrollView.backgroundColor = appCardBackground
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // Content container
        let contentView = UIView()
        contentView.backgroundColor = appCardBackground
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Top ad bar to avoid overlapping ad attribution over mediaView
        let topAdBar = UIView()
        topAdBar.backgroundColor = appCardBackground
        topAdBar.translatesAutoresizingMaskIntoConstraints = false

        // Ad label (top-left)
        let adLabel = UILabel()
        adLabel.text = "Ad"
        adLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        adLabel.backgroundColor = appSecondary
        adLabel.textColor = .white
        adLabel.textAlignment = .center
        adLabel.layer.cornerRadius = 4
        adLabel.clipsToBounds = true
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        topAdBar.addSubview(adLabel)

        // Large media view (hero section)
        let mediaView = MediaView()
        mediaView.backgroundColor = appCardBackground
        mediaView.layer.cornerRadius = 0 // Full width, no corner radius
        mediaView.translatesAutoresizingMaskIntoConstraints = false

        // Content container below media
        let textContentView = UIView()
        textContentView.backgroundColor = appCardBackground
        textContentView.translatesAutoresizingMaskIntoConstraints = false

        // App icon and title section
        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.spacing = 16
        headerStackView.alignment = .center
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        // Large app icon
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = .clear
        iconImageView.layer.cornerRadius = 16
        iconImageView.layer.shadowColor = UIColor.black.cgColor
        iconImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        iconImageView.layer.shadowRadius = 4
        iconImageView.layer.shadowOpacity = 0.05
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        // Title and rating section
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.spacing = 4
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false

        // Large headline
        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 26)
        headlineLabel.textColor = appTextPrimary
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false

        // Star rating view (placeholder)
        let ratingStackView = UIStackView()
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 2
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false

        // Add 5 star icons
        for _ in 0..<5 {
            let starLabel = UILabel()
            starLabel.text = "★"
            starLabel.font = UIFont.systemFont(ofSize: 16)
            starLabel.textColor = UIColor.systemYellow
            ratingStackView.addArrangedSubview(starLabel)
        }

        let ratingLabel = UILabel()
        ratingLabel.text = "4.8"
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        ratingLabel.textColor = appTextMuted
        ratingStackView.addArrangedSubview(ratingLabel)

        // Large install button
        let ctaButton = UIButton(type: .system)
        ctaButton.backgroundColor = appPrimary
        ctaButton.setTitleColor(.white, for: .normal)

        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        ctaButton.layer.cornerRadius = 12
        ctaButton.layer.shadowColor = appPrimary.cgColor
        ctaButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        ctaButton.layer.shadowRadius = 8
        ctaButton.layer.shadowOpacity = 0.2
        ctaButton.translatesAutoresizingMaskIntoConstraints = false

        // Detailed description
        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        bodyLabel.textColor = appTextMuted
        bodyLabel.numberOfLines = 0 // Unlimited lines for full screen
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        // Assemble header
        titleStackView.addArrangedSubview(headlineLabel)
        titleStackView.addArrangedSubview(ratingStackView)

        headerStackView.addArrangedSubview(iconImageView)
        headerStackView.addArrangedSubview(titleStackView)

        // Add all views to content
        textContentView.addSubview(headerStackView)
        textContentView.addSubview(ctaButton)
        textContentView.addSubview(bodyLabel)

        contentView.addSubview(mediaView)
        contentView.addSubview(textContentView)

        scrollView.addSubview(contentView)
        adView.addSubview(topAdBar)
        adView.addSubview(scrollView)

        // Constraints
        NSLayoutConstraint.activate([
            // Top ad bar constraints
            topAdBar.topAnchor.constraint(equalTo: adView.safeAreaLayoutGuide.topAnchor),
            topAdBar.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            topAdBar.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            topAdBar.heightAnchor.constraint(equalToConstant: 36),

            // Ad label constraints
            adLabel.leadingAnchor.constraint(equalTo: topAdBar.leadingAnchor, constant: 16),
            adLabel.centerYAnchor.constraint(equalTo: topAdBar.centerYAnchor),
            adLabel.widthAnchor.constraint(equalToConstant: 32),
            adLabel.heightAnchor.constraint(equalToConstant: 20),

            // Scroll view constraints (starts below topAdBar)
            scrollView.topAnchor.constraint(equalTo: topAdBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: adView.bottomAnchor),

            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Media view constraints (hero section)
            mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Text content view constraints
            textContentView.topAnchor.constraint(equalTo: mediaView.bottomAnchor),
            textContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Header stack view constraints
            headerStackView.topAnchor.constraint(equalTo: textContentView.topAnchor, constant: 24),
            headerStackView.leadingAnchor.constraint(equalTo: textContentView.leadingAnchor, constant: 20),
            headerStackView.trailingAnchor.constraint(equalTo: textContentView.trailingAnchor, constant: -20),

            // Icon constraints
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),

            // CTA button constraints
            ctaButton.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 24),
            ctaButton.leadingAnchor.constraint(equalTo: textContentView.leadingAnchor, constant: 20),
            ctaButton.trailingAnchor.constraint(equalTo: textContentView.trailingAnchor, constant: -20),
            ctaButton.heightAnchor.constraint(equalToConstant: 56),

            // Body label constraints
            bodyLabel.topAnchor.constraint(equalTo: ctaButton.bottomAnchor, constant: 24),
            bodyLabel.leadingAnchor.constraint(equalTo: textContentView.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: textContentView.trailingAnchor, constant: -20),
            bodyLabel.bottomAnchor.constraint(equalTo: textContentView.bottomAnchor, constant: -40),
        ])

        // Assign outlets
        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.iconView = iconImageView
        adView.callToActionView = ctaButton
        adView.mediaView = mediaView

        return configureFullScreenAdView(adView, with: nativeAd)
    }

    private func configureFullScreenAdView(_ adView: NativeAdView, with nativeAd: NativeAd) -> NativeAdView {
        print(">>> Swift NativeAdFactoryFullScreen: configureFullScreenAdView started")
        // Configure all views
        if let headlineView = adView.headlineView as? UILabel {
            headlineView.text = nativeAd.headline ?? "Amazing App"
        }

        if let bodyView = adView.bodyView as? UILabel {
            let bodyText = nativeAd.body ?? "Experience the ultimate app with incredible features and seamless performance. Download now and discover what millions of users already love about this amazing application."
            bodyView.text = bodyText
        }

        if let iconView = adView.iconView as? UIImageView {
            iconView.image = nativeAd.icon?.image
        }

        if let ctaView = adView.callToActionView as? UIButton {
            ctaView.setTitle(nativeAd.callToAction ?? "Install Now", for: .normal)
            ctaView.isUserInteractionEnabled = false
        }

        if let mediaView = adView.mediaView {
            mediaView.mediaContent = nativeAd.mediaContent

            // 1️⃣ Screen height for full-screen hero size
            let screenHeight = UIScreen.main.bounds.height
            let minHeroHeight = screenHeight * 0.65  // 65% full screen

            // 2️⃣ Apply minimum height (always)
            let minHeightConstraint = mediaView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: minHeroHeight
            )
            minHeightConstraint.priority = UILayoutPriority.required
            minHeightConstraint.isActive = true

            // 3️⃣ Apply aspect ratio (optional, lower priority)
            let aspect = CGFloat(nativeAd.mediaContent.aspectRatio)

            if aspect > 0 {
                let aspectConstraint = mediaView.heightAnchor.constraint(
                    equalTo: mediaView.widthAnchor,
                    multiplier: 1 / aspect
                )
                aspectConstraint.priority = UILayoutPriority.defaultHigh
                aspectConstraint.isActive = true
            }
        }


        adView.nativeAd = nativeAd

        // Full screen entrance animation
        adView.alpha = 0
        adView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
            adView.alpha = 1
            adView.transform = CGAffineTransform.identity
        })

        return adView
    }
}
