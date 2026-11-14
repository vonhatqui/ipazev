import UIKit

/// Card hiển thị chức năng phong cách Aurora với nút chọn ô vuông phát sáng (Square Checkbox)
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

    // Nút chọn ô vuông (Square Checkbox)
    private let squareBox = UIView()
    private let checkmarkIcon = UIImageView()

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

        // 3. Tag Label
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

        // 5. Square Checkbox (Nút ô vuông theo yêu cầu)
        squareBox.translatesAutoresizingMaskIntoConstraints = false
        squareBox.layer.cornerRadius = 7
        squareBox.layer.cornerCurve = .continuous
        squareBox.layer.borderWidth = 1.8
        squareBox.layer.borderColor = Theme.textDim.cgColor
        squareBox.clipsToBounds = true
        addSubview(squareBox)

        checkmarkIcon.translatesAutoresizingMaskIntoConstraints = false
        checkmarkIcon.image = UIImage(systemName: "checkmark")
        checkmarkIcon.tintColor = .white
        checkmarkIcon.contentMode = .scaleAspectFit
        squareBox.addSubview(checkmarkIcon)

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
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: squareBox.leadingAnchor, constant: -10),

            tagLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),

            targetPathLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            targetPathLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 3),
            targetPathLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            targetPathLabel.trailingAnchor.constraint(lessThanOrEqualTo: squareBox.leadingAnchor, constant: -10),

            squareBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            squareBox.centerYAnchor.constraint(equalTo: centerYAnchor),
            squareBox.widthAnchor.constraint(equalToConstant: 24),
            squareBox.heightAnchor.constraint(equalToConstant: 24),

            checkmarkIcon.centerXAnchor.constraint(equalTo: squareBox.centerXAnchor),
            checkmarkIcon.centerYAnchor.constraint(equalTo: squareBox.centerYAnchor),
            checkmarkIcon.widthAnchor.constraint(equalToConstant: 14),
            checkmarkIcon.heightAnchor.constraint(equalToConstant: 14)
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

                self.squareBox.backgroundColor = Theme.accent
                self.squareBox.layer.borderColor = Theme.accentLight.cgColor
                self.checkmarkIcon.alpha = 1.0
                self.checkmarkIcon.transform = .identity
            } else {
                self.backgroundColor = Theme.card
                self.layer.borderColor = Theme.cardStroke.cgColor
                self.layer.shadowOpacity = 0.0

                self.squareBox.backgroundColor = UIColor(white: 1.0, alpha: 0.04)
                self.squareBox.layer.borderColor = Theme.textDim.withAlphaComponent(0.6).cgColor
                self.checkmarkIcon.alpha = 0.0
                self.checkmarkIcon.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            }
        }

        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut], animations: block)
        } else {
            block()
        }
    }
}
