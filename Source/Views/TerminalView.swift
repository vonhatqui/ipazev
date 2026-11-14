import UIKit

/// Cửa sổ Terminal ma trận Hacker trực tiếp mô phỏng quá trình nạp cache & patch game mượt mà
public final class TerminalView: UIView {

    public var onFinished: (() -> Void)?

    private let dimView = UIView()
    private let panelView = UIView()
    private let titleBar = UIView()
    private let textView = UITextView()
    private let closeButton = UIButton(type: .system)

    private var lineQueue: [String] = []
    private var isEmitting = false
    public var lineDelay: TimeInterval = 0.08 // Giảm độ trễ để dòng xuất hiện mượt mà như hacker console

    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        // Dim Backdrop
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        addSubview(dimView)

        // Panel Container
        panelView.translatesAutoresizingMaskIntoConstraints = false
        panelView.backgroundColor = UIColor(red: 0.04, green: 0.02, blue: 0.08, alpha: 0.98)
        panelView.layer.cornerRadius = 18
        panelView.layer.cornerCurve = .continuous
        panelView.layer.borderWidth = 1.4
        panelView.layer.borderColor = Theme.accentLight.cgColor
        panelView.layer.shadowColor = Theme.accentGlow.cgColor
        panelView.layer.shadowRadius = 18
        panelView.layer.shadowOpacity = 0.75
        panelView.layer.shadowOffset = .zero
        panelView.clipsToBounds = true
        addSubview(panelView)

        // Title Bar
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        titleBar.backgroundColor = UIColor(red: 0.07, green: 0.04, blue: 0.14, alpha: 1.0)
        panelView.addSubview(titleBar)

        // 3 Traffic light dots
        let dotStack = UIStackView()
        dotStack.translatesAutoresizingMaskIntoConstraints = false
        dotStack.axis = .horizontal
        dotStack.spacing = 6
        for color in [UIColor(hex: 0xFF5F56), UIColor(hex: 0xFFBD2E), UIColor(hex: 0x27C93F)] {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = color
            dot.layer.cornerRadius = 5
            dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 10).isActive = true
            dotStack.addArrangedSubview(dot)
        }
        titleBar.addSubview(dotStack)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ZEVCHEAT LIVE INJECTOR"
        titleLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = Theme.textSub
        titleBar.addSubview(titleLabel)

        let statusPill = UILabel()
        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.text = "● RUNNING"
        statusPill.font = .monospacedSystemFont(ofSize: 10, weight: .heavy)
        statusPill.textColor = Theme.success
        titleBar.addSubview(statusPill)

        // Terminal TextView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = UIColor(red: 0.20, green: 0.95, blue: 0.60, alpha: 1.0)
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        textView.isEditable = false
        textView.isSelectable = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        panelView.addSubview(textView)

        // Close Button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("ĐÓNG TERMINAL", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        closeButton.setTitleColor(Theme.text, for: .normal)
        closeButton.backgroundColor = Theme.card
        closeButton.layer.cornerRadius = 12
        closeButton.layer.borderWidth = 1.0
        closeButton.layer.borderColor = Theme.cardStroke.cgColor
        closeButton.alpha = 0.0
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        panelView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            panelView.centerXAnchor.constraint(equalTo: centerXAnchor),
            panelView.centerYAnchor.constraint(equalTo: centerYAnchor),
            panelView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.92),
            panelView.heightAnchor.constraint(equalToConstant: 400),

            titleBar.topAnchor.constraint(equalTo: panelView.topAnchor),
            titleBar.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            titleBar.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 38),

            dotStack.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor, constant: 12),
            dotStack.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: titleBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),

            statusPill.trailingAnchor.constraint(equalTo: titleBar.trailingAnchor, constant: -12),
            statusPill.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),

            textView.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -8),

            closeButton.leadingAnchor.constraint(equalTo: panelView.leadingAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: panelView.trailingAnchor, constant: -16),
            closeButton.bottomAnchor.constraint(equalTo: panelView.bottomAnchor, constant: -14),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    public func present(in parentView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0.0
        panelView.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)

        parentView.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])

        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.alpha = 1.0
            self.panelView.transform = .identity
        }
    }

    public func dismiss() {
        UIView.animate(withDuration: 0.20, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0.0
            self.panelView.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            self.removeFromSuperview()
            self.onFinished?()
        }
    }

    @objc private func handleClose() {
        dismiss()
    }

    /// Đưa chuỗi log vào hàng đợi để gõ từng dòng mượt mà
    public func queueLogs(_ lines: [String]) {
        DispatchQueue.main.async {
            self.lineQueue.append(contentsOf: lines)
            if !self.isEmitting {
                self.emitNext()
            }
        }
    }

    private func emitNext() {
        guard !lineQueue.isEmpty else {
            isEmitting = false
            UIView.animate(withDuration: 0.3) {
                self.closeButton.alpha = 1.0
            }
            return
        }

        isEmitting = true
        let line = lineQueue.removeFirst()
        appendLine(line)

        DispatchQueue.main.asyncAfter(deadline: .now() + lineDelay) { [weak self] in
            self?.emitNext()
        }
    }

    private func appendLine(_ text: String) {
        let attr = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        let lineAttr: [NSAttributedString.Key: Any]

        if text.hasPrefix("[✓]") || text.hasPrefix("[★]") {
            lineAttr = [
                .foregroundColor: UIColor(red: 0.12, green: 0.95, blue: 0.52, alpha: 1.0),
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .bold)
            ]
        } else if text.hasPrefix("[*]") {
            lineAttr = [
                .foregroundColor: Theme.accentLight,
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
            ]
        } else if text.hasPrefix("[+]") {
            lineAttr = [
                .foregroundColor: UIColor(red: 0.30, green: 0.80, blue: 1.0, alpha: 1.0),
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
            ]
        } else if text.hasPrefix("[!]") {
            lineAttr = [
                .foregroundColor: Theme.danger,
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .bold)
            ]
        } else {
            lineAttr = [
                .foregroundColor: UIColor(red: 0.75, green: 0.85, blue: 0.95, alpha: 1.0),
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            ]
        }

        attr.append(NSAttributedString(string: "\(text)\n", attributes: lineAttr))
        textView.attributedText = attr

        // Cuộn xuống cuối một cách mượt mà
        if attr.length > 0 {
            let bottom = NSRange(location: attr.length - 1, length: 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
}

// Extension helper màu Hex
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}
