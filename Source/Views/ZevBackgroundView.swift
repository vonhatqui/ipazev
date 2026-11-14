import UIKit

/// Background động ZevCheatiOS Dark Cyber với hiệu ứng nhịp thở phát sáng huyền ảo (Breathing glow)
public final class ZevBackgroundView: UIView {

    private let glowTop = CAGradientLayer()
    private let glowBottom = CAGradientLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGlow()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGlow()
    }

    private func setupGlow() {
        backgroundColor = Theme.bg

        // Glow tím ở đỉnh màn hình (Top radial aura)
        glowTop.type = .radial
        glowTop.colors = [
            UIColor(red: 0.616, green: 0.306, blue: 0.867, alpha: 0.45).cgColor, // #9d4edd
            UIColor(red: 0.533, green: 0.0, blue: 0.973, alpha: 0.20).cgColor,   // #8800f8
            UIColor.clear.cgColor
        ]
        glowTop.locations = [0.0, 0.55, 1.0]
        glowTop.startPoint = CGPoint(x: 0.5, y: 0.15)
        glowTop.endPoint = CGPoint(x: 1.0, y: 0.65)
        layer.addSublayer(glowTop)

        // Glow tím huyền ảo ở đáy màn hình (Bottom aura)
        glowBottom.type = .radial
        glowBottom.colors = [
            UIColor(red: 0.722, green: 0.161, blue: 0.984, alpha: 0.35).cgColor,
            UIColor(red: 0.384, green: 0.094, blue: 0.596, alpha: 0.15).cgColor,
            UIColor.clear.cgColor
        ]
        glowBottom.locations = [0.0, 0.60, 1.0]
        glowBottom.startPoint = CGPoint(x: 0.5, y: 0.85)
        glowBottom.endPoint = CGPoint(x: 1.0, y: 1.35)
        layer.addSublayer(glowBottom)

        animateBreath()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        glowTop.frame = CGRect(x: -bounds.width * 0.2, y: -bounds.height * 0.15, width: bounds.width * 1.4, height: bounds.height * 0.7)
        glowBottom.frame = CGRect(x: -bounds.width * 0.2, y: bounds.height * 0.45, width: bounds.width * 1.4, height: bounds.height * 0.7)
    }

    /// Hiệu ứng nhịp thở phát sáng huyền ảo liên tục
    private func animateBreath() {
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 0.65
        anim.toValue = 1.0
        anim.duration = 3.6
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowTop.add(anim, forKey: "breathTop")

        let animBottom = CABasicAnimation(keyPath: "opacity")
        animBottom.fromValue = 0.45
        animBottom.toValue = 0.90
        animBottom.duration = 4.2
        animBottom.autoreverses = true
        animBottom.repeatCount = .infinity
        animBottom.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowBottom.add(animBottom, forKey: "breathBottom")
    }
}

/// Typealias tương thích ngược cho các file đã mở trong editor
public typealias AuroraBackgroundView = ZevBackgroundView

