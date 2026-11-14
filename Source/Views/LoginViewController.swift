import UIKit

/// Màn hình Đăng nhập & Xác thực License chuẩn phong cách Aurora Dark Cyber
public final class LoginViewController: UIViewController, UITextFieldDelegate {

    private let backgroundView = ZevBackgroundView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let badgeView = VerifiedBadge()

    private let cardContainer = UIView()
    private let hwidBox = UIView()
    private let hwidTitleLabel = UILabel()
    private let hwidValueLabel = UILabel()
    private let copyHwidButton = UIButton(type: .system)

    private let keyFieldContainer = UIView()
    private let keyTextField = UITextField()
    private let pasteKeyButton = UIButton(type: .system)

    private let activateButton = NeonButton(title: "KÍCH HOẠT LICENSE")
    private let langButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkMaintenance()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupUI() {
        view.backgroundColor = Theme.bg

        // 1. Ambient Background
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        // 2. Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // 3. Logo Gengar New - Hiển thị 100% trọn vẹn, không bị cắt 1/3
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = false
        if let logo = UIImage(named: "logo.png") {
            logoImageView.image = logo
        } else {
            logoImageView.image = UIImage(systemName: "bolt.shield.fill")
        }
        logoImageView.layer.shadowColor = Theme.accentGlow.cgColor
        logoImageView.layer.shadowRadius = 14
        logoImageView.layer.shadowOpacity = 0.65
        logoImageView.layer.shadowOffset = .zero
        contentView.addSubview(logoImageView)

        // 4. Title & Subtitle
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ZevCheatiOS"
        titleLabel.font = .systemFont(ofSize: 26, weight: .heavy)
        titleLabel.textColor = Theme.text
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Tactical Container Injector · VIP Edition"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        subtitleLabel.textColor = Theme.accentLight
        subtitleLabel.textAlignment = .center
        contentView.addSubview(subtitleLabel)

        // 5. Badge iOS Support
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.configure(supported: true, text: "iOS 17.0 - 18.2+ VERIFIED / SAFE")
        contentView.addSubview(badgeView)

        // 6. Card Container chính
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.backgroundColor = Theme.card
        cardContainer.layer.cornerRadius = 20
        cardContainer.layer.cornerCurve = .continuous
        cardContainer.layer.borderWidth = 1.2
        cardContainer.layer.borderColor = Theme.cardStroke.cgColor
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.4
        cardContainer.layer.shadowRadius = 10
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(cardContainer)

        // HWID Box
        hwidBox.translatesAutoresizingMaskIntoConstraints = false
        hwidBox.backgroundColor = Theme.bgElevated
        hwidBox.layer.cornerRadius = 12
        hwidBox.layer.borderWidth = 1.0
        hwidBox.layer.borderColor = Theme.cardStroke.cgColor
        cardContainer.addSubview(hwidBox)

        hwidTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hwidTitleLabel.text = "MÃ THIẾT BỊ (HWID)"
        hwidTitleLabel.font = .systemFont(ofSize: 10, weight: .bold)
        hwidTitleLabel.textColor = Theme.textDim
        hwidBox.addSubview(hwidTitleLabel)

        hwidValueLabel.translatesAutoresizingMaskIntoConstraints = false
        hwidValueLabel.text = APIService.shared.deviceHWID
        hwidValueLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        hwidValueLabel.textColor = Theme.textSub
        hwidValueLabel.lineBreakMode = .byTruncatingMiddle
        hwidBox.addSubview(hwidValueLabel)

        copyHwidButton.translatesAutoresizingMaskIntoConstraints = false
        copyHwidButton.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
        copyHwidButton.tintColor = Theme.accentLight
        copyHwidButton.addTarget(self, action: #selector(handleCopyHWID), for: .touchUpInside)
        hwidBox.addSubview(copyHwidButton)

        // Key Input Container
        keyFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        keyFieldContainer.backgroundColor = Theme.bgElevated
        keyFieldContainer.layer.cornerRadius = 14
        keyFieldContainer.layer.borderWidth = 1.2
        keyFieldContainer.layer.borderColor = Theme.cardStroke.cgColor
        cardContainer.addSubview(keyFieldContainer)

        keyTextField.translatesAutoresizingMaskIntoConstraints = false
        keyTextField.placeholder = "Nhập hoặc dán mã Key VIP..."
        keyTextField.textColor = Theme.text
        keyTextField.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        keyTextField.autocapitalizationType = .allCharacters
        keyTextField.autocorrectionType = .no
        keyTextField.returnKeyType = .done
        keyTextField.delegate = self
        keyTextField.attributedPlaceholder = NSAttributedString(
            string: "Nhập mã Key VIP...",
            attributes: [.foregroundColor: Theme.textDim]
        )
        keyFieldContainer.addSubview(keyTextField)

        pasteKeyButton.translatesAutoresizingMaskIntoConstraints = false
        pasteKeyButton.setTitle("DÁN", for: .normal)
        pasteKeyButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .heavy)
        pasteKeyButton.setTitleColor(Theme.accentLight, for: .normal)
        pasteKeyButton.addTarget(self, action: #selector(handlePasteKey), for: .touchUpInside)
        keyFieldContainer.addSubview(pasteKeyButton)

        // Activate Button
        activateButton.translatesAutoresizingMaskIntoConstraints = false
        activateButton.addTarget(self, action: #selector(handleActivate), for: .touchUpInside)
        cardContainer.addSubview(activateButton)

        // Language Pill Button
        langButton.translatesAutoresizingMaskIntoConstraints = false
        langButton.setTitle("🌐 Tiếng Việt (VN)", for: .normal)
        langButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        langButton.setTitleColor(Theme.textDim, for: .normal)
        contentView.addSubview(langButton)

        // Status Label & Activity
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = Theme.textSub
        cardContainer.addSubview(statusLabel)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = Theme.accentLight
        activityIndicator.hidesWhenStopped = true
        cardContainer.addSubview(activityIndicator)

        // Layout Constraints
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            badgeView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            badgeView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            cardContainer.topAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: 18),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            hwidBox.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 16),
            hwidBox.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 16),
            hwidBox.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
            hwidBox.heightAnchor.constraint(equalToConstant: 50),

            hwidTitleLabel.topAnchor.constraint(equalTo: hwidBox.topAnchor, constant: 8),
            hwidTitleLabel.leadingAnchor.constraint(equalTo: hwidBox.leadingAnchor, constant: 12),

            hwidValueLabel.bottomAnchor.constraint(equalTo: hwidBox.bottomAnchor, constant: -8),
            hwidValueLabel.leadingAnchor.constraint(equalTo: hwidBox.leadingAnchor, constant: 12),
            hwidValueLabel.trailingAnchor.constraint(equalTo: copyHwidButton.leadingAnchor, constant: -8),

            copyHwidButton.trailingAnchor.constraint(equalTo: hwidBox.trailingAnchor, constant: -10),
            copyHwidButton.centerYAnchor.constraint(equalTo: hwidBox.centerYAnchor),
            copyHwidButton.widthAnchor.constraint(equalToConstant: 30),
            copyHwidButton.heightAnchor.constraint(equalToConstant: 30),

            keyFieldContainer.topAnchor.constraint(equalTo: hwidBox.bottomAnchor, constant: 14),
            keyFieldContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 16),
            keyFieldContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
            keyFieldContainer.heightAnchor.constraint(equalToConstant: 48),

            keyTextField.leadingAnchor.constraint(equalTo: keyFieldContainer.leadingAnchor, constant: 14),
            keyTextField.centerYAnchor.constraint(equalTo: keyFieldContainer.centerYAnchor),
            keyTextField.trailingAnchor.constraint(equalTo: pasteKeyButton.leadingAnchor, constant: -8),

            pasteKeyButton.trailingAnchor.constraint(equalTo: keyFieldContainer.trailingAnchor, constant: -12),
            pasteKeyButton.centerYAnchor.constraint(equalTo: keyFieldContainer.centerYAnchor),
            pasteKeyButton.widthAnchor.constraint(equalToConstant: 44),

            activateButton.topAnchor.constraint(equalTo: keyFieldContainer.bottomAnchor, constant: 16),
            activateButton.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 16),
            activateButton.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
            activateButton.heightAnchor.constraint(equalToConstant: 48),

            activityIndicator.centerYAnchor.constraint(equalTo: activateButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: activateButton.trailingAnchor, constant: -16),

            statusLabel.topAnchor.constraint(equalTo: activateButton.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -16),

            langButton.topAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: 16),
            langButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            langButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func checkMaintenance() {
        APIService.shared.checkMaintenanceStatus { [weak self] isMaint, msg in
            if isMaint {
                self?.statusLabel.textColor = Theme.warning
                self?.statusLabel.text = "⚠️ \(msg ?? "Hệ thống đang bảo trì. Vui lòng quay lại sau.")"
                self?.activateButton.setEnabledStyle(false)
            }
        }
    }

    @objc private func handleCopyHWID() {
        UIPasteboard.general.string = APIService.shared.deviceHWID
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        statusLabel.textColor = Theme.success
        statusLabel.text = "✓ Đã sao chép mã HWID vào bộ nhớ tạm!"
    }

    @objc private func handlePasteKey() {
        if let clip = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) {
            keyTextField.text = clip
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }
    }

    @objc private func handleActivate() {
        guard let key = keyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !key.isEmpty else {
            statusLabel.textColor = Theme.danger
            statusLabel.text = "Vui lòng nhập mã Key VIP của bạn!"
            return
        }

        view.endEditing(true)
        activateButton.setEnabledStyle(false)
        activityIndicator.startAnimating()
        statusLabel.textColor = Theme.textSub
        statusLabel.text = "Đang kết nối server & xác thực thiết bị..."

        APIService.shared.validateKey(key: key) { [weak self] success, err, licenseInfo in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.activateButton.setEnabledStyle(true)

            if success, let info = licenseInfo {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.statusLabel.textColor = Theme.success
                self.statusLabel.text = "✓ Xác thực thành công! Đang vào ứng dụng..."

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    let mainVC = MainViewController(key: key, licenseInfo: info)
                    mainVC.modalPresentationStyle = .fullScreen
                    mainVC.modalTransitionStyle = .crossDissolve
                    self.present(mainVC, animated: true)
                }
            } else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                self.statusLabel.textColor = Theme.danger
                self.statusLabel.text = "✕ \(err ?? "Key không hợp lệ hoặc đã hết hạn!")"
            }
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        handleActivate()
        return true
    }
}
