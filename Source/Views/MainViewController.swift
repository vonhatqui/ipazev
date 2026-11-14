import UIKit

public final class MainViewController: UIViewController {

    private let key: String
    private let licenseInfo: [String: Any]
    private var selectedBundleId = "com.dts.freefireth" // Mặc định Free Fire thường
    private var features: [[String: Any]] = []

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerView = UIView()
    private let licenseBox = UIView()
    private let countdownLabel = UILabel()
    private let gameSegment = UISegmentedControl(items: ["Free Fire", "Free Fire MAX"])

    private let featuresStack = UIStackView()
    private let injectButton = UIButton(type: .system)
    private let installDnsButton = UIButton(type: .system)
    private let launchGameButton = UIButton(type: .system)
    private let logLabel = UILabel()

    public init(key: String, licenseInfo: [String: Any]) {
        self.key = key
        self.licenseInfo = licenseInfo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFeatures()
        startCountdown()
        LocalConfigServer.shared.start()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    private func setupUI() {
        view.backgroundColor = Theme.bg

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
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

        // 1. Header
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ZevCheatiOS · VIP Engine"
        titleLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        titleLabel.textColor = Theme.text

        // 2. License Box
        licenseBox.translatesAutoresizingMaskIntoConstraints = false
        licenseBox.backgroundColor = Theme.card
        licenseBox.layer.cornerRadius = 16
        licenseBox.layer.borderColor = Theme.cardStroke.cgColor
        licenseBox.layer.borderWidth = 1.2

        let keyBadge = UILabel()
        keyBadge.translatesAutoresizingMaskIntoConstraints = false
        keyBadge.text = "VIP KEY: \(key)"
        keyBadge.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        keyBadge.textColor = Theme.accentLight

        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.font = .monospacedSystemFont(ofSize: 15, weight: .heavy)
        countdownLabel.textColor = Theme.success
        countdownLabel.text = "ĐANG TẢI THỜI HẠN..."

        licenseBox.addSubview(keyBadge)
        licenseBox.addSubview(countdownLabel)

        // 3. Game Selector Segment
        gameSegment.translatesAutoresizingMaskIntoConstraints = false
        gameSegment.selectedSegmentIndex = 0
        gameSegment.backgroundColor = Theme.card
        gameSegment.selectedSegmentTintColor = Theme.accentGlow
        gameSegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .bold)], for: .selected)
        gameSegment.setTitleTextAttributes([.foregroundColor: Theme.textSub, .font: UIFont.systemFont(ofSize: 13, weight: .medium)], for: .normal)
        gameSegment.addTarget(self, action: #selector(handleGameChanged), for: .valueChanged)

        // 4. Features Stack
        featuresStack.translatesAutoresizingMaskIntoConstraints = false
        featuresStack.axis = .vertical
        featuresStack.spacing = 10

        // 5. Action Buttons
        injectButton.translatesAutoresizingMaskIntoConstraints = false
        injectButton.setTitle("⚡ NẠP CACHE VÀO DOCUMENTS", for: .normal)
        injectButton.setTitleColor(.white, for: .normal)
        injectButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .heavy)
        injectButton.backgroundColor = Theme.accentGlow
        injectButton.layer.cornerRadius = 14
        injectButton.layer.shadowColor = Theme.accentGlow.cgColor
        injectButton.layer.shadowOpacity = 0.5
        injectButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        injectButton.layer.shadowRadius = 10
        injectButton.addTarget(self, action: #selector(handleInjectAll), for: .touchUpInside)

        launchGameButton.translatesAutoresizingMaskIntoConstraints = false
        launchGameButton.setTitle("▶ KHỞI CHẠY GAME", for: .normal)
        launchGameButton.setTitleColor(.white, for: .normal)
        launchGameButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        launchGameButton.backgroundColor = UIColor(red: 0.1, green: 0.6, blue: 0.35, alpha: 1.0)
        launchGameButton.layer.cornerRadius = 14
        launchGameButton.addTarget(self, action: #selector(handleLaunchGame), for: .touchUpInside)

        installDnsButton.translatesAutoresizingMaskIntoConstraints = false
        installDnsButton.setTitle("🛡 Cài Đặt Profile DNS / Proxy", for: .normal)
        installDnsButton.setTitleColor(Theme.accentLight, for: .normal)
        installDnsButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        installDnsButton.backgroundColor = Theme.accentDim
        installDnsButton.layer.cornerRadius = 12
        installDnsButton.layer.borderColor = Theme.cardStroke.cgColor
        installDnsButton.layer.borderWidth = 1.0
        installDnsButton.addTarget(self, action: #selector(handleInstallDns), for: .touchUpInside)

        logLabel.translatesAutoresizingMaskIntoConstraints = false
        logLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        logLabel.textColor = Theme.textDim
        logLabel.numberOfLines = 4
        logLabel.textAlignment = .center
        logLabel.text = "Sẵn sàng nạp cache vào Documents của game."

        contentView.addSubview(titleLabel)
        contentView.addSubview(licenseBox)
        contentView.addSubview(gameSegment)
        contentView.addSubview(featuresStack)
        contentView.addSubview(injectButton)
        contentView.addSubview(launchGameButton)
        contentView.addSubview(installDnsButton)
        contentView.addSubview(logLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            licenseBox.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            licenseBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            licenseBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            licenseBox.heightAnchor.constraint(equalToConstant: 68),

            keyBadge.topAnchor.constraint(equalTo: licenseBox.topAnchor, constant: 12),
            keyBadge.leadingAnchor.constraint(equalTo: licenseBox.leadingAnchor, constant: 16),

            countdownLabel.bottomAnchor.constraint(equalTo: licenseBox.bottomAnchor, constant: -12),
            countdownLabel.leadingAnchor.constraint(equalTo: licenseBox.leadingAnchor, constant: 16),

            gameSegment.topAnchor.constraint(equalTo: licenseBox.bottomAnchor, constant: 16),
            gameSegment.leadingAnchor.constraint(equalTo: licenseBox.leadingAnchor),
            gameSegment.trailingAnchor.constraint(equalTo: licenseBox.trailingAnchor),
            gameSegment.heightAnchor.constraint(equalToConstant: 40),

            featuresStack.topAnchor.constraint(equalTo: gameSegment.bottomAnchor, constant: 18),
            featuresStack.leadingAnchor.constraint(equalTo: licenseBox.leadingAnchor),
            featuresStack.trailingAnchor.constraint(equalTo: licenseBox.trailingAnchor),

            injectButton.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 22),
            injectButton.leadingAnchor.constraint(equalTo: licenseBox.leadingAnchor),
            injectButton.trailingAnchor.constraint(equalTo: licenseBox.trailingAnchor),
            injectButton.heightAnchor.constraint(equalToConstant: 50),

            launchGameButton.topAnchor.constraint(equalTo: injectButton.bottomAnchor, constant: 10),
            launchGameButton.leadingAnchor.constraint(equalTo: licenseBox.leadingAnchor),
            launchGameButton.trailingAnchor.constraint(equalTo: licenseBox.trailingAnchor),
            launchGameButton.heightAnchor.constraint(equalToConstant: 46),

            installDnsButton.topAnchor.constraint(equalTo: launchGameButton.bottomAnchor, constant: 10),
            installDnsButton.leadingAnchor.constraint(equalTo: licenseBox.leadingAnchor),
            installDnsButton.trailingAnchor.constraint(equalTo: licenseBox.trailingAnchor),
            installDnsButton.heightAnchor.constraint(equalToConstant: 42),

            logLabel.topAnchor.constraint(equalTo: installDnsButton.bottomAnchor, constant: 14),
            logLabel.leadingAnchor.constraint(equalTo: licenseBox.leadingAnchor),
            logLabel.trailingAnchor.constraint(equalTo: licenseBox.trailingAnchor),
            logLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func startCountdown() {
        let expMs = (licenseInfo["expiresAt"] as? Double) ?? 0
        let expSec = expMs / 1000.0

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            let rem = max(0, Int(expSec - Date().timeIntervalSince1970))
            let d = rem / 86400
            let h = (rem % 86400) / 3600
            let m = (rem % 3600) / 60
            let s = rem % 60
            self?.countdownLabel.text = String(format: "HẾT HẠN: %d ngày %02d:%02d:%02d", d, h, m, s)
        }
    }

    private func loadFeatures() {
        APIService.shared.fetchFeatures(key: key) { [weak self] ok, list in
            DispatchQueue.main.async {
                self?.features = list
                self?.renderFeatureCards()
            }
        }
    }

    private func renderFeatureCards() {
        featuresStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for f in features {
            let card = UIView()
            card.backgroundColor = Theme.card
            card.layer.cornerRadius = 12
            card.layer.borderColor = Theme.cardStroke.cgColor
            card.layer.borderWidth = 1.0
            card.translatesAutoresizingMaskIntoConstraints = false
            card.heightAnchor.constraint(equalToConstant: 58).isActive = true

            let nameLbl = UILabel()
            nameLbl.translatesAutoresizingMaskIntoConstraints = false
            nameLbl.text = (f["name"] as? String) ?? "Feature"
            nameLbl.font = .systemFont(ofSize: 14, weight: .bold)
            nameLbl.textColor = Theme.text

            let descLbl = UILabel()
            descLbl.translatesAutoresizingMaskIntoConstraints = false
            descLbl.text = (f["targetPath"] as? String) ?? ""
            descLbl.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
            descLbl.textColor = Theme.textDim

            let checkIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            checkIcon.translatesAutoresizingMaskIntoConstraints = false
            checkIcon.tintColor = Theme.success

            card.addSubview(nameLbl)
            card.addSubview(descLbl)
            card.addSubview(checkIcon)

            NSLayoutConstraint.activate([
                checkIcon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                checkIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                checkIcon.widthAnchor.constraint(equalToConstant: 20),
                checkIcon.heightAnchor.constraint(equalToConstant: 20),

                nameLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
                nameLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                nameLbl.trailingAnchor.constraint(equalTo: checkIcon.leadingAnchor, constant: -10),

                descLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
                descLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                descLbl.trailingAnchor.constraint(equalTo: checkIcon.leadingAnchor, constant: -10)
            ])

            featuresStack.addArrangedSubview(card)
        }
    }

    @objc private func handleGameChanged() {
        selectedBundleId = (gameSegment.selectedSegmentIndex == 0) ? "com.dts.freefireth" : "com.dts.freefiremax"
        logLabel.text = "Đã chuyển mục tiêu sang: \(selectedBundleId)"
    }

    @objc private func handleInjectAll() {
        guard !features.isEmpty else { return }
        injectButton.isEnabled = false
        injectButton.setTitle("ĐANG NẠP CACHE...", for: .normal)
        logLabel.text = "Bắt đầu tải và nạp file vào Documents..."

        let group = DispatchGroup()
        var successCount = 0

        for f in features {
            guard let dlUrl = f["downloadUrl"] as? String,
                  let targetPath = f["targetPath"] as? String,
                  let slot = f["slot"] as? String else { continue }

            group.enter()
            APIService.shared.downloadSlotFile(urlStr: dlUrl) { [weak self] data, pathHeader, err in
                defer { group.leave() }
                if let data = data, let self = self {
                    let relPath = pathHeader ?? targetPath
                    do {
                        _ = try FileReplacer.shared.injectFile(data: data, bundleId: self.selectedBundleId, relativePath: relPath)
                        successCount += 1
                        APIService.shared.reportInjection(key: self.key, slot: slot, success: true)
                    } catch {
                        APIService.shared.reportInjection(key: self.key, slot: slot, success: false, error: error.localizedDescription)
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.injectButton.isEnabled = true
            self.injectButton.setTitle("⚡ NẠP CACHE VÀO DOCUMENTS", for: .normal)
            self.logLabel.text = "✓ Đã nạp thành công \(successCount)/\(self.features.count) gói cache vào game!"

            let alert = UIAlertController(title: "Nạp Cache Thành Công!", message: "Đã nạp đầy đủ các gói cache vào Documents của \(self.selectedBundleId). Bạn có muốn mở game ngay bây giờ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Mở Game Ngay", style: .default, handler: { _ in
                _ = FileReplacer.shared.launchGame(bundleId: self.selectedBundleId)
            }))
            alert.addAction(UIAlertAction(title: "Để Sau", style: .cancel))
            self.present(alert, animated: true)
        }
    }

    @objc private func handleLaunchGame() {
        if !FileReplacer.shared.launchGame(bundleId: selectedBundleId) {
            logLabel.text = "Không thể khởi chạy trực tiếp. Vui lòng mở game từ màn hình chính!"
        }
    }

    @objc private func handleInstallDns() {
        let port = LocalConfigServer.shared.port
        if let url = URL(string: "http://127.0.0.1:\(port)/ZevCheatiOS.mobileconfig") {
            UIApplication.shared.open(url)
        }
    }
}
