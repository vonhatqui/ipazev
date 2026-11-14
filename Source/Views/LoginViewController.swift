import UIKit
import Darwin

// MARK: - Device Model Identifier Extension
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "x86_64", "arm64", "i386": return "iPhone 15 Pro Max"
        default:
            if identifier.starts(with: "iPhone") {
                return identifier.replacingOccurrences(of: ",", with: ".")
            }
            return UIDevice.current.model
        }
    }
}

/// Màn hình Đăng nhập & Xác thực License chuẩn phong cách Aurora (ProxyIPA)
public final class LoginViewController: UIViewController, UITextFieldDelegate {

    private let backgroundView = ZevBackgroundView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header Logo & Aurora Title
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // Device Info Card (Aurora Style)
    private let deviceCardView = UIView()
    private let modelTitleLabel = UILabel()
    private let modelValueLabel = UILabel()
    private let osTitleLabel = UILabel()
    private let osValueLabel = UILabel()
    private let supportTitleLabel = UILabel()
    private let verifiedBadge = UIView()
    private let verifiedIcon = UIImageView()
    private let verifiedLabel = UILabel()

    // Key Input Section
    private let keySectionLabel = UILabel()
    private let keyFieldContainer = UIView()
    private let keyTextField = UITextField()
    private let pasteKeyButton = UIButton(type: .system)

    // Status / Warning Label
    private let statusLabel = UILabel()

    // Action Button & Lang Pill
    private let activateButton = NeonButton(title: "Kích Hoạt")
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let langButton = UIButton(type: .system)

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

        // 3. Small Logo (Không viền đen, nền trong suốt hoàn toàn)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = false
        if let logo = UIImage(named: "logo.png") {
            logoImageView.image = logo
        } else {
            logoImageView.image = UIImage(systemName: "bolt.shield.fill")
        }
        logoImageView.layer.shadowColor = UIColor(red: 0.65, green: 0.35, blue: 0.95, alpha: 1.0).cgColor
        logoImageView.layer.shadowRadius = 14
        logoImageView.layer.shadowOpacity = 0.55
        logoImageView.layer.shadowOffset = .zero
        contentView.addSubview(logoImageView)

        // 4. Stylized Aurora Gradient Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        let auroraAttr = NSMutableAttributedString()
        let letters: [(String, UIColor)] = [
            ("A", UIColor(red: 0.68, green: 0.38, blue: 0.96, alpha: 1.0)), // Violet
            ("U", UIColor(red: 0.88, green: 0.36, blue: 0.88, alpha: 1.0)), // Pink-magenta
            ("R", UIColor(red: 0.68, green: 0.38, blue: 0.96, alpha: 1.0)), // Violet
            ("O", UIColor(red: 0.22, green: 0.82, blue: 0.96, alpha: 1.0)), // Cyan neon
            ("R", UIColor(red: 0.96, green: 0.44, blue: 0.72, alpha: 1.0)), // Pink
            ("A", UIColor(red: 0.96, green: 0.96, blue: 1.00, alpha: 1.0))  // Ice white
        ]
        for (char, color) in letters {
            auroraAttr.append(NSAttributedString(string: char, attributes: [
                .font: UIFont.systemFont(ofSize: 32, weight: .black),
                .foregroundColor: color,
                .kern: 5.0
            ]))
        }
        titleLabel.attributedText = auroraAttr
        contentView.addSubview(titleLabel)

        // 5. Subtitle: PROXYIPA
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.attributedText = NSAttributedString(string: "PROXYIPA", attributes: [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor(red: 0.60, green: 0.65, blue: 0.75, alpha: 1.0),
            .kern: 7.0
        ])
        contentView.addSubview(subtitleLabel)

        // 6. Device Info Card (Chuẩn giao diện Aurora)
        deviceCardView.translatesAutoresizingMaskIntoConstraints = false
        deviceCardView.backgroundColor = UIColor(red: 0.10, green: 0.08, blue: 0.17, alpha: 0.92)
        deviceCardView.layer.cornerRadius = 18
        deviceCardView.layer.cornerCurve = .continuous
        deviceCardView.layer.borderWidth = 1.0
        deviceCardView.layer.borderColor = UIColor(white: 1.0, alpha: 0.09).cgColor
        deviceCardView.isUserInteractionEnabled = true
        let tapCard = UITapGestureRecognizer(target: self, action: #selector(handleCopyHWID))
        deviceCardView.addGestureRecognizer(tapCard)
        contentView.addSubview(deviceCardView)

        // Row 1: Model Thiết Bị
        modelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        modelTitleLabel.text = "Model Thiết Bị"
        modelTitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        modelTitleLabel.textColor = UIColor(red: 0.62, green: 0.66, blue: 0.76, alpha: 1.0)
        deviceCardView.addSubview(modelTitleLabel)

        modelValueLabel.translatesAutoresizingMaskIntoConstraints = false
        modelValueLabel.text = UIDevice.current.modelName
        modelValueLabel.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        modelValueLabel.textColor = .white
        modelValueLabel.textAlignment = .right
        deviceCardView.addSubview(modelValueLabel)

        // Row 2: Phiên Bản iOS
        osTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        osTitleLabel.text = "Phiên Bản iOS"
        osTitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        osTitleLabel.textColor = UIColor(red: 0.62, green: 0.66, blue: 0.76, alpha: 1.0)
        deviceCardView.addSubview(osTitleLabel)

        osValueLabel.translatesAutoresizingMaskIntoConstraints = false
        osValueLabel.text = "iOS \(UIDevice.current.systemVersion)"
        osValueLabel.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        osValueLabel.textColor = .white
        osValueLabel.textAlignment = .right
        deviceCardView.addSubview(osValueLabel)

        // Row 3: Được Hỗ Trợ -> Badge "Đã xác minh"
        supportTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        supportTitleLabel.text = "Được Hỗ Trợ"
        supportTitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        supportTitleLabel.textColor = UIColor(red: 0.62, green: 0.66, blue: 0.76, alpha: 1.0)
        deviceCardView.addSubview(supportTitleLabel)

        verifiedBadge.translatesAutoresizingMaskIntoConstraints = false
        verifiedBadge.backgroundColor = UIColor(red: 0.06, green: 0.22, blue: 0.15, alpha: 1.0)
        verifiedBadge.layer.cornerRadius = 10
        verifiedBadge.layer.borderWidth = 1.0
        verifiedBadge.layer.borderColor = UIColor(red: 0.12, green: 0.68, blue: 0.45, alpha: 0.5).cgColor
        deviceCardView.addSubview(verifiedBadge)

        verifiedIcon.translatesAutoresizingMaskIntoConstraints = false
        verifiedIcon.image = UIImage(systemName: "checkmark.shield.fill")
        verifiedIcon.tintColor = UIColor(red: 0.16, green: 0.78, blue: 0.52, alpha: 1.0)
        verifiedIcon.contentMode = .scaleAspectFit
        verifiedBadge.addSubview(verifiedIcon)

        verifiedLabel.translatesAutoresizingMaskIntoConstraints = false
        verifiedLabel.text = "Đã xác minh"
        verifiedLabel.font = .systemFont(ofSize: 12, weight: .bold)
        verifiedLabel.textColor = UIColor(red: 0.16, green: 0.78, blue: 0.52, alpha: 1.0)
        verifiedBadge.addSubview(verifiedLabel)

        // 7. Nhập Khóa Giấy Phép Header
        keySectionLabel.translatesAutoresizingMaskIntoConstraints = false
        keySectionLabel.text = "Nhập Khóa Giấy Phép"
        keySectionLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        keySectionLabel.textColor = UIColor(red: 0.65, green: 0.70, blue: 0.80, alpha: 1.0)
        contentView.addSubview(keySectionLabel)

        // 8. Key Field Container
        keyFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        keyFieldContainer.backgroundColor = UIColor(red: 0.09, green: 0.07, blue: 0.15, alpha: 0.95)
        keyFieldContainer.layer.cornerRadius = 14
        keyFieldContainer.layer.cornerCurve = .continuous
        keyFieldContainer.layer.borderWidth = 1.0
        keyFieldContainer.layer.borderColor = UIColor(white: 1.0, alpha: 0.12).cgColor
        contentView.addSubview(keyFieldContainer)

        keyTextField.translatesAutoresizingMaskIntoConstraints = false
        keyTextField.textColor = .white
        keyTextField.font = .monospacedSystemFont(ofSize: 15, weight: .bold)
        keyTextField.autocapitalizationType = .allCharacters
        keyTextField.autocorrectionType = .no
        keyTextField.returnKeyType = .done
        keyTextField.delegate = self
        keyTextField.attributedPlaceholder = NSAttributedString(
            string: "ZEV-LIFETIME-01",
            attributes: [.foregroundColor: UIColor(white: 0.35, alpha: 1.0)]
        )
        keyFieldContainer.addSubview(keyTextField)

        pasteKeyButton.translatesAutoresizingMaskIntoConstraints = false
        pasteKeyButton.setTitle("DÁN", for: .normal)
        pasteKeyButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .heavy)
        pasteKeyButton.setTitleColor(Theme.accentLight, for: .normal)
        pasteKeyButton.addTarget(self, action: #selector(handlePasteKey), for: .touchUpInside)
        keyFieldContainer.addSubview(pasteKeyButton)

        // 9. Status / Warning Label (Ẩn mặc định, hiển thị khi có lỗi)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textColor = UIColor(red: 0.97, green: 0.44, blue: 0.49, alpha: 1.0) // Soft rose red
        statusLabel.numberOfLines = 0
        statusLabel.text = ""
        contentView.addSubview(statusLabel)

        // 10. Activate Button ("Kích Hoạt")
        activateButton.translatesAutoresizingMaskIntoConstraints = false
        activateButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        activateButton.addTarget(self, action: #selector(handleActivate), for: .touchUpInside)
        contentView.addSubview(activateButton)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activateButton.addSubview(activityIndicator)

        // 11. Bottom Language Pill
        langButton.translatesAutoresizingMaskIntoConstraints = false
        langButton.setTitle("🌐 Tiếng Việt", for: .normal)
        langButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        langButton.setTitleColor(UIColor(red: 0.72, green: 0.76, blue: 0.86, alpha: 1.0), for: .normal)
        langButton.backgroundColor = UIColor(red: 0.08, green: 0.06, blue: 0.14, alpha: 0.8)
        langButton.layer.cornerRadius = 18
        langButton.layer.borderWidth = 1.0
        langButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.08).cgColor
        contentView.addSubview(langButton)

        // Layout Constraints
        NSLayoutConstraint.activate([
            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 72),
            logoImageView.heightAnchor.constraint(equalToConstant: 72),

            // Aurora Title & Subtitle
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Device Info Card
            deviceCardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 22),
            deviceCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deviceCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Row 1
            modelTitleLabel.topAnchor.constraint(equalTo: deviceCardView.topAnchor, constant: 18),
            modelTitleLabel.leadingAnchor.constraint(equalTo: deviceCardView.leadingAnchor, constant: 18),

            modelValueLabel.centerYAnchor.constraint(equalTo: modelTitleLabel.centerYAnchor),
            modelValueLabel.trailingAnchor.constraint(equalTo: deviceCardView.trailingAnchor, constant: -18),
            modelValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: modelTitleLabel.trailingAnchor, constant: 10),

            // Row 2
            osTitleLabel.topAnchor.constraint(equalTo: modelTitleLabel.bottomAnchor, constant: 16),
            osTitleLabel.leadingAnchor.constraint(equalTo: deviceCardView.leadingAnchor, constant: 18),

            osValueLabel.centerYAnchor.constraint(equalTo: osTitleLabel.centerYAnchor),
            osValueLabel.trailingAnchor.constraint(equalTo: deviceCardView.trailingAnchor, constant: -18),

            // Row 3
            supportTitleLabel.topAnchor.constraint(equalTo: osTitleLabel.bottomAnchor, constant: 18),
            supportTitleLabel.leadingAnchor.constraint(equalTo: deviceCardView.leadingAnchor, constant: 18),
            supportTitleLabel.bottomAnchor.constraint(equalTo: deviceCardView.bottomAnchor, constant: -18),

            verifiedBadge.centerYAnchor.constraint(equalTo: supportTitleLabel.centerYAnchor),
            verifiedBadge.trailingAnchor.constraint(equalTo: deviceCardView.trailingAnchor, constant: -18),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 28),

            verifiedIcon.leadingAnchor.constraint(equalTo: verifiedBadge.leadingAnchor, constant: 8),
            verifiedIcon.centerYAnchor.constraint(equalTo: verifiedBadge.centerYAnchor),
            verifiedIcon.widthAnchor.constraint(equalToConstant: 14),
            verifiedIcon.heightAnchor.constraint(equalToConstant: 14),

            verifiedLabel.leadingAnchor.constraint(equalTo: verifiedIcon.trailingAnchor, constant: 6),
            verifiedLabel.trailingAnchor.constraint(equalTo: verifiedBadge.trailingAnchor, constant: -10),
            verifiedLabel.centerYAnchor.constraint(equalTo: verifiedBadge.centerYAnchor),

            // Section Label
            keySectionLabel.topAnchor.constraint(equalTo: deviceCardView.bottomAnchor, constant: 22),
            keySectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            keySectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),

            // Input Box
            keyFieldContainer.topAnchor.constraint(equalTo: keySectionLabel.bottomAnchor, constant: 10),
            keyFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            keyFieldContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            keyFieldContainer.heightAnchor.constraint(equalToConstant: 52),

            keyTextField.leadingAnchor.constraint(equalTo: keyFieldContainer.leadingAnchor, constant: 16),
            keyTextField.centerYAnchor.constraint(equalTo: keyFieldContainer.centerYAnchor),
            keyTextField.trailingAnchor.constraint(equalTo: pasteKeyButton.leadingAnchor, constant: -8),

            pasteKeyButton.trailingAnchor.constraint(equalTo: keyFieldContainer.trailingAnchor, constant: -14),
            pasteKeyButton.centerYAnchor.constraint(equalTo: keyFieldContainer.centerYAnchor),
            pasteKeyButton.widthAnchor.constraint(equalToConstant: 44),

            // Status Label (Warning)
            statusLabel.topAnchor.constraint(equalTo: keyFieldContainer.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),

            // Activate Button
            activateButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 14),
            activateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activateButton.heightAnchor.constraint(equalToConstant: 52),

            activityIndicator.centerYAnchor.constraint(equalTo: activateButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: activateButton.trailingAnchor, constant: -18),

            // Language Pill
            langButton.topAnchor.constraint(equalTo: activateButton.bottomAnchor, constant: 22),
            langButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            langButton.widthAnchor.constraint(equalToConstant: 130),
            langButton.heightAnchor.constraint(equalToConstant: 36),
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
        statusLabel.text = "✓ Đã sao chép mã HWID thiết bị vào bộ nhớ tạm!"
    }

    @objc private func handlePasteKey() {
        if let clip = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) {
            keyTextField.text = clip
            statusLabel.text = ""
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }
    }

    @objc private func handleActivate() {
        guard let key = keyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !key.isEmpty else {
            statusLabel.textColor = UIColor(red: 0.97, green: 0.44, blue: 0.49, alpha: 1.0)
            statusLabel.text = "⚠️ Vui lòng nhập khóa giấy phép của bạn!"
            return
        }

        view.endEditing(true)
        activateButton.setEnabledStyle(false)
        activityIndicator.startAnimating()
        statusLabel.textColor = Theme.textSub
        statusLabel.text = "Đang kết nối máy chủ & kích hoạt giấy phép..."

        APIService.shared.validateKey(key: key) { [weak self] success, err, licenseInfo in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.activateButton.setEnabledStyle(true)

            if success, let info = licenseInfo {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.statusLabel.textColor = Theme.success
                self.statusLabel.text = "✓ Kích hoạt thành công! Đang vào ứng dụng..."

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    let mainVC = MainViewController(key: key, licenseInfo: info)
                    mainVC.modalPresentationStyle = .fullScreen
                    mainVC.modalTransitionStyle = .crossDissolve
                    self.present(mainVC, animated: true)
                }
            } else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                self.statusLabel.textColor = UIColor(red: 0.97, green: 0.44, blue: 0.49, alpha: 1.0)
                let message = err ?? "Khóa không hợp lệ hoặc đã hết hạn."
                self.statusLabel.text = "⚠️ \(message)"
            }
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        handleActivate()
        return true
    }
}
