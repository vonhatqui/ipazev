import UIKit

/// Card hiển thị chức năng phong cách Aurora với nút radio neon và hiệu ứng chọn phát sáng
public final class FeatureCardView: UIView {

    public var onSelectionChanged: ((Bool) -> Void)?

    public var isSelected: Bool = false {
        didSet {
            applyState(animated: true)
        }
    }

    public let featureData: [String: Any]

    private let badge = UIView()
    private let badgeIcon = UIImageView()
    private let nameLabel = UILabel()
    private let tagLabel = UILabel()
    private let targetPathLabel = UILabel()
    private let radio = UIView()
    private let radioDot = UIView()

    public init(feature: [String: Any], selected: Bool = false) {
        self.featureData = feature
        self.isSelected = selected
        super.init(frame: .zero)
        setupUI()
        applyState(animated: false)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Theme.card
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 1.4
        layer.borderColor = Theme.cardStroke.cgColor

        // Bật tương tác chạm
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        // 1. Icon Badge container
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = Theme.accentDim
        badge.layer.cornerRadius = 12
        badge.layer.borderWidth = 1.0
        badge.layer.borderColor = Theme.cardStroke.cgColor
        addSubview(badge)

        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeIcon.contentMode = .scaleAspectFit
        badgeIcon.tintColor = Theme.accentLight

        // Load icon từ asset hoặc SF Symbol
        let iconName = featureData["icon"] as? String ?? "sparkles"
        if let customImg = UIImage(named: "\(iconName).png") {
            badgeIcon.image = customImg
        } else {
            badgeIcon.image = UIImage(systemName: iconName) ?? UIImage(systemName: "bolt.shield.fill")
        }
        badge.addSubview(badgeIcon)

        // 2. Name Label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = featureData["name"] as? String ?? "VIP Feature"
        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        nameLabel.textColor = Theme.text
        addSubview(nameLabel)

        // 3. Tag Label (v2.108.x · Compulsory · SAFE)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        let ver = featureData["version"] as? String ?? "v1.0"
        let tag = featureData["tag"] as? String ?? "SAFE"
        tagLabel.text = "\(ver) · \(tag)"
        tagLabel.font = .monospacedSystemFont(ofSize: 11, weight: .semibold)
        tagLabel.textColor = Theme.accentLight
        addSubview(tagLabel)

        // 4. Target Path Subtitle
        targetPathLabel.translatesAutoresizingMaskIntoConstraints = false
        targetPathLabel.text = featureData["target_path"] as? String ?? "Documents/cache"
        targetPathLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        targetPathLabel.textColor = Theme.textDim
        addSubview(targetPathLabel)

        // 5. Radio Button Outer
        radio.translatesAutoresizingMaskIntoConstraints = false
        radio.layer.cornerRadius = 11
        radio.layer.borderWidth = 1.8
        radio.layer.borderColor = Theme.textDim.cgColor
        addSubview(radio)

        // Radio Dot Inner
        radioDot.translatesAutoresizingMaskIntoConstraints = false
        radioDot.layer.cornerRadius = 6
        radioDot.backgroundColor = Theme.accentLight
        radio.addSubview(radioDot)

        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            badge.centerYAnchor.constraint(equalTo: centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: 42),
            badge.heightAnchor.constraint(equalToConstant: 42),

            badgeIcon.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            badgeIcon.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            badgeIcon.widthAnchor.constraint(equalToConstant: 24),
            badgeIcon.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: radio.leadingAnchor, constant: -10),

            tagLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),

            targetPathLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            targetPathLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 3),
            targetPathLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            targetPathLabel.trailingAnchor.constraint(lessThanOrEqualTo: radio.leadingAnchor, constant: -10),

            radio.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            radio.centerYAnchor.constraint(equalTo: centerYAnchor),
            radio.widthAnchor.constraint(equalToConstant: 22),
            radio.heightAnchor.constraint(equalToConstant: 22),

            radioDot.centerXAnchor.constraint(equalTo: radio.centerXAnchor),
            radioDot.centerYAnchor.constraint(equalTo: radio.centerYAnchor),
            radioDot.widthAnchor.constraint(equalToConstant: 12),
            radioDot.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    @objc private func handleTap() {
        isSelected.toggle()
        onSelectionChanged?(isSelected)
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }

    private func applyState(animated: Bool) {
        let block = {
            if self.isSelected {
                self.backgroundColor = Theme.bgElevated
                self.layer.borderColor = Theme.accentLight.cgColor
                self.layer.shadowColor = Theme.accentGlow.cgColor
                self.layer.shadowRadius = 8
                self.layer.shadowOpacity = 0.55
                self.layer.shadowOffset = .zero

                self.radio.layer.borderColor = Theme.accentLight.cgColor
                self.radioDot.alpha = 1.0
                self.radioDot.transform = .identity
            } else {
                self.backgroundColor = Theme.card
                self.layer.borderColor = Theme.cardStroke.cgColor
                self.layer.shadowOpacity = 0.0

                self.radio.layer.borderColor = Theme.textDim.cgColor
                self.radioDot.alpha = 0.0
                self.radioDot.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            }
        }

        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut], animations: block)
        } else {
            block()
        }
    }
}

