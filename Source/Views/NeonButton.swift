import UIKit

/// Nút bấm Neon Cyber phong cách Aurora với viền phát sáng và hiệu ứng đàn hồi Spring
public final class NeonButton: UIButton {

    private let gradientLayer = CAGradientLayer()

    public init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupStyle()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    private func setupStyle() {
        titleLabel?.font = .systemFont(ofSize: 15, weight: .heavy)
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)

        layer.cornerRadius = 15
        layer.cornerCurve = .continuous
        clipsToBounds = false

        // Viền phát sáng Neon Cyber
        layer.borderWidth = 1.6
        layer.borderColor = Theme.accentLight.cgColor

        // Đổ bóng phát sáng (Neon Outer Glow)
        layer.shadowColor = Theme.accentGlow.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.65

        // Gradient nền tím đậm sang tím sáng
        gradientLayer.colors = [
            UIColor(red: 0.616, green: 0.306, blue: 0.867, alpha: 0.95).cgColor, // #9d4edd
            UIColor(red: 0.443, green: 0.047, blue: 0.776, alpha: 0.95).cgColor  // #710cc6
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 15
        gradientLayer.cornerCurve = .continuous
        layer.insertSublayer(gradientLayer, at: 0)

        // Phản hồi chạm
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
    }

    public func setEnabledStyle(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1.0 : 0.45
        layer.shadowOpacity = enabled ? 0.65 : 0.0
    }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.88
            self.layer.shadowRadius = 4
        }
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = .identity
            self.alpha = self.isEnabled ? 1.0 : 0.45
            self.layer.shadowRadius = 10
        }
    }
}

