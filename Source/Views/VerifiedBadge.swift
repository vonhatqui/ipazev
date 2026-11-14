import UIKit

/// Huy hiệu xác nhận bảo vệ & tương thích phiên bản hệ thống (Verified Shield Pill)
public final class VerifiedBadge: UIView {

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = Theme.card
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        layer.borderWidth = 1.0
        layer.borderColor = Theme.cardStroke.cgColor

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "checkmark.shield.fill")
        iconImageView.tintColor = Theme.success
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = Theme.textSub
        titleLabel.text = "iOS 17.0 - 18.2+ VERIFIED"

        addSubview(iconImageView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 14),
            iconImageView.heightAnchor.constraint(equalToConstant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }

    public func configure(supported: Bool, text: String) {
        titleLabel.text = text
        if supported {
            iconImageView.image = UIImage(systemName: "checkmark.shield.fill")
            iconImageView.tintColor = Theme.success
            layer.borderColor = Theme.accentLight.withAlphaComponent(0.4).cgColor
        } else {
            iconImageView.image = UIImage(systemName: "exclamationmark.shield.fill")
            iconImageView.tintColor = Theme.danger
            layer.borderColor = Theme.danger.withAlphaComponent(0.4).cgColor
        }
    }
}

