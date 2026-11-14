import UIKit

/// Màn hình điều khiển chính ZevCheatiOS chuẩn phong cách Aurora với hệ thống Tab, Terminal ma trận & Camouflage
public final class MainViewController: UIViewController {

    private let key: String
    private let licenseInfo: [String: Any]
    private var selectedBundleId = "com.dts.freefireth" // Free Fire thường

    private let backgroundView = ZevBackgroundView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerView = UIView()
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let licenseCard = UIView()
    private let keyBadgeLabel = UILabel()
    private let countdownLabel = UILabel()
    private var countdownTimer: Timer?

    // Tab Bar (Segmented Control phong cách Aurora)
    private let tabSegment = UISegmentedControl(items: ["NẠP CACHE", "DNS PROXY", "NGỤY TRANG", "CÀI ĐẶT"])
    private let tabContainer = UIView()

    // Pages
    private let featuresPage = UIView()
    private let dnsPage = UIView()
    private let camouflagePage = UIView()
    private let settingsPage = UIView()

    // Features Page components
    private let gameSegment = UISegmentedControl(items: ["Free Fire", "Free Fire MAX"])
    private let featuresStack = UIStackView()
    private var cardViews: [FeatureCardView] = []
    private let injectButton = NeonButton(title: "⚡ INJECT VÀO GAME NGAY")

    // Terminal
    private var activeTerminal: TerminalView?

    public init(key: String, licenseInfo: [String: Any]) {
        self.key = key
        self.licenseInfo = licenseInfo
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFeatures()
        startCountdown()
        LocalConfigServer.shared.start()
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

        // 3. Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        if let img = UIImage(named: "logo.png") {
            logoImageView.image = img
        } else {
            logoImageView.image = UIImage(systemName: "bolt.shield.fill")
        }
        logoImageView.layer.shadowColor = Theme.accentGlow.cgColor
        logoImageView.layer.shadowRadius = 8
        logoImageView.layer.shadowOpacity = 0.5
        headerView.addSubview(logoImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ZevCheatiOS"
        titleLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = Theme.text
        headerView.addSubview(titleLabel)

        let vipPill = UILabel()
        vipPill.translatesAutoresizingMaskIntoConstraints = false
        vipPill.text = "VIP ACTIVE"
        vipPill.font = .monospacedSystemFont(ofSize: 10, weight: .bold)
        vipPill.textColor = Theme.success
        vipPill.backgroundColor = Theme.card
        vipPill.layer.cornerRadius = 6
        vipPill.layer.borderWidth = 1.0
        vipPill.layer.borderColor = Theme.success.withAlphaComponent(0.4).cgColor
        vipPill.clipsToBounds = true
        vipPill.textAlignment = .center
        headerView.addSubview(vipPill)

        // License Card
        licenseCard.translatesAutoresizingMaskIntoConstraints = false
        licenseCard.backgroundColor = Theme.card
        licenseCard.layer.cornerRadius = 14
        licenseCard.layer.borderWidth = 1.0
        licenseCard.layer.borderColor = Theme.cardStroke.cgColor
        contentView.addSubview(licenseCard)

        keyBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        keyBadgeLabel.text = "KEY: \(key)"
        keyBadgeLabel.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        keyBadgeLabel.textColor = Theme.accentLight
        licenseCard.addSubview(keyBadgeLabel)

        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.font = .monospacedSystemFont(ofSize: 14, weight: .heavy)
        countdownLabel.textColor = Theme.success
        countdownLabel.text = "HẠN DÙNG: ĐANG TẢI..."
        licenseCard.addSubview(countdownLabel)

        // 4. Tab Segmented Control
        tabSegment.translatesAutoresizingMaskIntoConstraints = false
        tabSegment.selectedSegmentIndex = 0
        tabSegment.backgroundColor = Theme.card
        tabSegment.selectedSegmentTintColor = Theme.accentGlow
        tabSegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11, weight: .bold)], for: .selected)
        tabSegment.setTitleTextAttributes([.foregroundColor: Theme.textDim, .font: UIFont.systemFont(ofSize: 11, weight: .medium)], for: .normal)
        tabSegment.addTarget(self, action: #selector(handleTabChanged), for: .valueChanged)
        contentView.addSubview(tabSegment)

        // 5. Container for Pages
        tabContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabContainer)

        setupFeaturesPage()
        setupDNSPage()
        setupCamouflagePage()
        setupSettingsPage()

        showPage(index: 0)

        // Layout Constraints Header & Tabs
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            headerView.heightAnchor.constraint(equalToConstant: 44),

            logoImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 44),
            logoImageView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            vipPill.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            vipPill.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            vipPill.widthAnchor.constraint(equalToConstant: 72),
            vipPill.heightAnchor.constraint(equalToConstant: 20),

            licenseCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 14),
            licenseCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            licenseCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            licenseCard.heightAnchor.constraint(equalToConstant: 64),

            keyBadgeLabel.topAnchor.constraint(equalTo: licenseCard.topAnchor, constant: 12),
            keyBadgeLabel.leadingAnchor.constraint(equalTo: licenseCard.leadingAnchor, constant: 14),

            countdownLabel.bottomAnchor.constraint(equalTo: licenseCard.bottomAnchor, constant: -12),
            countdownLabel.leadingAnchor.constraint(equalTo: licenseCard.leadingAnchor, constant: 14),

            tabSegment.topAnchor.constraint(equalTo: licenseCard.bottomAnchor, constant: 16),
            tabSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            tabSegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            tabSegment.heightAnchor.constraint(equalToConstant: 36),

            tabContainer.topAnchor.constraint(equalTo: tabSegment.bottomAnchor, constant: 14),
            tabContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            tabContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            tabContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Tab 0: Features Page (Nạp Cache)
    private func setupFeaturesPage() {
        featuresPage.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.addSubview(featuresPage)

        gameSegment.translatesAutoresizingMaskIntoConstraints = false
        gameSegment.selectedSegmentIndex = 0
        gameSegment.backgroundColor = Theme.card
        gameSegment.selectedSegmentTintColor = Theme.accent
        gameSegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12, weight: .bold)], for: .selected)
        gameSegment.setTitleTextAttributes([.foregroundColor: Theme.textDim, .font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
        gameSegment.addTarget(self, action: #selector(handleGameChanged), for: .valueChanged)
        featuresPage.addSubview(gameSegment)

        featuresStack.translatesAutoresizingMaskIntoConstraints = false
        featuresStack.axis = .vertical
        featuresStack.spacing = 10
        featuresPage.addSubview(featuresStack)

        injectButton.translatesAutoresizingMaskIntoConstraints = false
        injectButton.addTarget(self, action: #selector(handleInjectTapped), for: .touchUpInside)
        featuresPage.addSubview(injectButton)

        NSLayoutConstraint.activate([
            featuresPage.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            featuresPage.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            featuresPage.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            featuresPage.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),

            gameSegment.topAnchor.constraint(equalTo: featuresPage.topAnchor),
            gameSegment.leadingAnchor.constraint(equalTo: featuresPage.leadingAnchor),
            gameSegment.trailingAnchor.constraint(equalTo: featuresPage.trailingAnchor),
            gameSegment.heightAnchor.constraint(equalToConstant: 34),

            featuresStack.topAnchor.constraint(equalTo: gameSegment.bottomAnchor, constant: 14),
            featuresStack.leadingAnchor.constraint(equalTo: featuresPage.leadingAnchor),
            featuresStack.trailingAnchor.constraint(equalTo: featuresPage.trailingAnchor),

            injectButton.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 18),
            injectButton.leadingAnchor.constraint(equalTo: featuresPage.leadingAnchor),
            injectButton.trailingAnchor.constraint(equalTo: featuresPage.trailingAnchor),
            injectButton.heightAnchor.constraint(equalToConstant: 50),
            injectButton.bottomAnchor.constraint(equalTo: featuresPage.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Tab 1: DNS Proxy Page
    private func setupDNSPage() {
        dnsPage.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.addSubview(dnsPage)

        let dnsCard = UIView()
        dnsCard.translatesAutoresizingMaskIntoConstraints = false
        dnsCard.backgroundColor = Theme.card
        dnsCard.layer.cornerRadius = 16
        dnsCard.layer.borderWidth = 1.0
        dnsCard.layer.borderColor = Theme.cardStroke.cgColor
        dnsPage.addSubview(dnsCard)

        let dnsIcon = UIImageView(image: UIImage(systemName: "antenna.radiowaves.left.and.right"))
        dnsIcon.translatesAutoresizingMaskIntoConstraints = false
        dnsIcon.tintColor = Theme.accentLight
        dnsIcon.contentMode = .scaleAspectFit
        dnsCard.addSubview(dnsIcon)

        let dnsTitle = UILabel()
        dnsTitle.translatesAutoresizingMaskIntoConstraints = false
        dnsTitle.text = "Cấu Hình DoH DNS Chặn Ban"
        dnsTitle.font = .systemFont(ofSize: 16, weight: .bold)
        dnsTitle.textColor = Theme.text
        dnsCard.addSubview(dnsTitle)

        let dnsDesc = UILabel()
        dnsDesc.translatesAutoresizingMaskIntoConstraints = false
        dnsDesc.text = "Định tuyến DNS qua máy chủ bảo vệ để tự động chặn các domain ghi nhận telemetry, báo cáo gian lận và quét chữ ký của Free Fire."
        dnsDesc.font = .systemFont(ofSize: 12, weight: .regular)
        dnsDesc.textColor = Theme.textSub
        dnsDesc.numberOfLines = 0
        dnsCard.addSubview(dnsDesc)

        let installDNSBtn = NeonButton(title: "📥 CÀI PROFILE DNS (.MOBILECONFIG)")
        installDNSBtn.translatesAutoresizingMaskIntoConstraints = false
        installDNSBtn.addTarget(self, action: #selector(handleInstallDNS), for: .touchUpInside)
        dnsPage.addSubview(installDNSBtn)

        let resetGuestBtn = UIButton(type: .system)
        resetGuestBtn.translatesAutoresizingMaskIntoConstraints = false
        resetGuestBtn.setTitle("🗑️ XÓA DỮ LIỆU TÀI KHOẢN KHÁCH (RESET GUEST)", for: .normal)
        resetGuestBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        resetGuestBtn.setTitleColor(Theme.danger, for: .normal)
        resetGuestBtn.backgroundColor = Theme.card
        resetGuestBtn.layer.cornerRadius = 12
        resetGuestBtn.layer.borderWidth = 1.0
        resetGuestBtn.layer.borderColor = Theme.danger.withAlphaComponent(0.4).cgColor
        resetGuestBtn.addTarget(self, action: #selector(handleResetGuest), for: .touchUpInside)
        dnsPage.addSubview(resetGuestBtn)

        NSLayoutConstraint.activate([
            dnsPage.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            dnsPage.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            dnsPage.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            dnsPage.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),

            dnsCard.topAnchor.constraint(equalTo: dnsPage.topAnchor),
            dnsCard.leadingAnchor.constraint(equalTo: dnsPage.leadingAnchor),
            dnsCard.trailingAnchor.constraint(equalTo: dnsPage.trailingAnchor),

            dnsIcon.leadingAnchor.constraint(equalTo: dnsCard.leadingAnchor, constant: 16),
            dnsIcon.topAnchor.constraint(equalTo: dnsCard.topAnchor, constant: 16),
            dnsIcon.widthAnchor.constraint(equalToConstant: 32),
            dnsIcon.heightAnchor.constraint(equalToConstant: 32),

            dnsTitle.leadingAnchor.constraint(equalTo: dnsIcon.trailingAnchor, constant: 12),
            dnsTitle.centerYAnchor.constraint(equalTo: dnsIcon.centerYAnchor),
            dnsTitle.trailingAnchor.constraint(equalTo: dnsCard.trailingAnchor, constant: -16),

            dnsDesc.topAnchor.constraint(equalTo: dnsIcon.bottomAnchor, constant: 12),
            dnsDesc.leadingAnchor.constraint(equalTo: dnsCard.leadingAnchor, constant: 16),
            dnsDesc.trailingAnchor.constraint(equalTo: dnsCard.trailingAnchor, constant: -16),
            dnsDesc.bottomAnchor.constraint(equalTo: dnsCard.bottomAnchor, constant: -16),

            installDNSBtn.topAnchor.constraint(equalTo: dnsCard.bottomAnchor, constant: 16),
            installDNSBtn.leadingAnchor.constraint(equalTo: dnsPage.leadingAnchor),
            installDNSBtn.trailingAnchor.constraint(equalTo: dnsPage.trailingAnchor),
            installDNSBtn.heightAnchor.constraint(equalToConstant: 48),

            resetGuestBtn.topAnchor.constraint(equalTo: installDNSBtn.bottomAnchor, constant: 14),
            resetGuestBtn.leadingAnchor.constraint(equalTo: dnsPage.leadingAnchor),
            resetGuestBtn.trailingAnchor.constraint(equalTo: dnsPage.trailingAnchor),
            resetGuestBtn.heightAnchor.constraint(equalToConstant: 44),
            resetGuestBtn.bottomAnchor.constraint(equalTo: dnsPage.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Tab 2: Camouflage (Ngụy trang App Icon)
    private func setupCamouflagePage() {
        camouflagePage.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.addSubview(camouflagePage)

        let titleCard = UILabel()
        titleCard.translatesAutoresizingMaskIntoConstraints = false
        titleCard.text = "Đổi Biểu Tượng App Ngoài Màn Hình Chính"
        titleCard.font = .systemFont(ofSize: 14, weight: .bold)
        titleCard.textColor = Theme.textSub
        camouflagePage.addSubview(titleCard)

        let icons = [
            ("calculator", "Máy tính"),
            ("camera", "Máy ảnh"),
            ("capcut", "CapCut"),
            ("chatgpt", "ChatGPT"),
            ("facebook", "Facebook"),
            ("instagram", "Instagram"),
            ("tiktok", "TikTok"),
            ("whatsapp", "WhatsApp"),
            ("youtube", "YouTube")
        ]

        let gridStack = UIStackView()
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.axis = .vertical
        gridStack.spacing = 10
        camouflagePage.addSubview(gridStack)

        var rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 10
        rowStack.distribution = .fillEqually

        for (idx, item) in icons.enumerated() {
            if idx > 0 && idx % 3 == 0 {
                gridStack.addArrangedSubview(rowStack)
                rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.spacing = 10
                rowStack.distribution = .fillEqually
            }

            let btn = UIButton(type: .system)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.backgroundColor = Theme.card
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = Theme.cardStroke.cgColor

            let stack = UIStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 6
            stack.isUserInteractionEnabled = false
            btn.addSubview(stack)

            let iconView = UIImageView()
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.contentMode = .scaleAspectFit
            iconView.layer.cornerRadius = 8
            iconView.clipsToBounds = true
            if let custom = UIImage(named: "\(item.0)@2x.png") {
                iconView.image = custom
            } else {
                iconView.image = UIImage(systemName: "app.fill")
                iconView.tintColor = Theme.accentLight
            }
            iconView.widthAnchor.constraint(equalToConstant: 32).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 32).isActive = true
            stack.addArrangedSubview(iconView)

            let lbl = UILabel()
            lbl.text = item.1
            lbl.font = .systemFont(ofSize: 11, weight: .semibold)
            lbl.textColor = Theme.textSub
            stack.addArrangedSubview(lbl)

            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
                btn.heightAnchor.constraint(equalToConstant: 72)
            ])

            btn.tag = idx
            btn.addTarget(self, action: #selector(handleSelectIcon(_:)), for: .touchUpInside)
            rowStack.addArrangedSubview(btn)
        }
        gridStack.addArrangedSubview(rowStack)

        NSLayoutConstraint.activate([
            camouflagePage.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            camouflagePage.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            camouflagePage.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            camouflagePage.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),

            titleCard.topAnchor.constraint(equalTo: camouflagePage.topAnchor),
            titleCard.leadingAnchor.constraint(equalTo: camouflagePage.leadingAnchor),

            gridStack.topAnchor.constraint(equalTo: titleCard.bottomAnchor, constant: 12),
            gridStack.leadingAnchor.constraint(equalTo: camouflagePage.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: camouflagePage.trailingAnchor),
            gridStack.bottomAnchor.constraint(equalTo: camouflagePage.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Tab 3: Settings Page
    private func setupSettingsPage() {
        settingsPage.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.addSubview(settingsPage)

        let infoCard = UIView()
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        infoCard.backgroundColor = Theme.card
        infoCard.layer.cornerRadius = 16
        infoCard.layer.borderWidth = 1.0
        infoCard.layer.borderColor = Theme.cardStroke.cgColor
        settingsPage.addSubview(infoCard)

        let infoTitle = UILabel()
        infoTitle.translatesAutoresizingMaskIntoConstraints = false
        infoTitle.text = "THÔNG TIN HỆ THỐNG"
        infoTitle.font = .systemFont(ofSize: 13, weight: .heavy)
        infoTitle.textColor = Theme.accentLight
        infoCard.addSubview(infoTitle)

        let serverLabel = UILabel()
        serverLabel.translatesAutoresizingMaskIntoConstraints = false
        serverLabel.text = "Máy chủ: \(APIService.shared.baseURL)"
        serverLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        serverLabel.textColor = Theme.textSub
        infoCard.addSubview(serverLabel)

        let hwidLabel = UILabel()
        hwidLabel.translatesAutoresizingMaskIntoConstraints = false
        hwidLabel.text = "HWID: \(APIService.shared.deviceHWID)"
        hwidLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        hwidLabel.textColor = Theme.textDim
        hwidLabel.lineBreakMode = .byTruncatingMiddle
        infoCard.addSubview(hwidLabel)

        let logoutBtn = UIButton(type: .system)
        logoutBtn.translatesAutoresizingMaskIntoConstraints = false
        logoutBtn.setTitle("ĐĂNG XUẤT LICENSE", for: .normal)
        logoutBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        logoutBtn.setTitleColor(Theme.danger, for: .normal)
        logoutBtn.backgroundColor = Theme.card
        logoutBtn.layer.cornerRadius = 14
        logoutBtn.layer.borderWidth = 1.0
        logoutBtn.layer.borderColor = Theme.danger.withAlphaComponent(0.4).cgColor
        logoutBtn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        settingsPage.addSubview(logoutBtn)

        NSLayoutConstraint.activate([
            settingsPage.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            settingsPage.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            settingsPage.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            settingsPage.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),

            infoCard.topAnchor.constraint(equalTo: settingsPage.topAnchor),
            infoCard.leadingAnchor.constraint(equalTo: settingsPage.leadingAnchor),
            infoCard.trailingAnchor.constraint(equalTo: settingsPage.trailingAnchor),

            infoTitle.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 14),
            infoTitle.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),

            serverLabel.topAnchor.constraint(equalTo: infoTitle.bottomAnchor, constant: 8),
            serverLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            serverLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),

            hwidLabel.topAnchor.constraint(equalTo: serverLabel.bottomAnchor, constant: 6),
            hwidLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            hwidLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            hwidLabel.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -16),

            logoutBtn.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 18),
            logoutBtn.leadingAnchor.constraint(equalTo: settingsPage.leadingAnchor),
            logoutBtn.trailingAnchor.constraint(equalTo: settingsPage.trailingAnchor),
            logoutBtn.heightAnchor.constraint(equalToConstant: 48),
            logoutBtn.bottomAnchor.constraint(equalTo: settingsPage.bottomAnchor, constant: -10)
        ])
    }

    private func showPage(index: Int) {
        featuresPage.isHidden = index != 0
        dnsPage.isHidden = index != 1
        camouflagePage.isHidden = index != 2
        settingsPage.isHidden = index != 3
    }

    @objc private func handleTabChanged() {
        showPage(index: tabSegment.selectedSegmentIndex)
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }

    @objc private func handleGameChanged() {
        selectedBundleId = gameSegment.selectedSegmentIndex == 0 ? "com.dts.freefireth" : "com.dts.freefiremax"
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
    }

    private func loadFeatures() {
        APIService.shared.fetchFeatures(key: key) { [weak self] success, list in
            guard let self = self else { return }
            self.features = list
            self.renderFeatureCards()
        }
    }

    private var features: [[String: Any]] = []

    private func renderFeatureCards() {
        featuresStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()

        for item in features {
            let card = FeatureCardView(feature: item, selected: true)
            cardViews.append(card)
            featuresStack.addArrangedSubview(card)
        }
    }

    @objc private func handleInjectTapped() {
        let selectedCards = cardViews.filter { $0.isSelected }
        guard !selectedCards.isEmpty else {
            let alert = UIAlertController(title: "Chưa chọn tính năng", message: "Vui lòng chọn ít nhất 1 chức năng để nạp vào game!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Khởi tạo Terminal Matrix View
        let term = TerminalView(frame: view.bounds)
        activeTerminal = term
        term.present(in: view)

        term.queueLogs([
            "[*] Initializing ZevCheatiOS Tactical Injector v1.0.0...",
            "[*] Authenticating license session key...",
            "[+] Target Game: \(selectedBundleId == "com.dts.freefireth" ? "Free Fire" : "Free Fire MAX") (\(selectedBundleId))",
            "[*] Querying iOS Sandbox Container Manager (libsystem_containermanager)..."
        ])

        // Thực hiện nạp từng slot
        let group = DispatchGroup()
        for c in selectedCards {
            let slotKey = c.featureData["slot"] as? String ?? ""
            let name = c.featureData["name"] as? String ?? slotKey
            let targetPath = c.featureData["target_path"] as? String ?? ""

            group.enter()
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                term.queueLogs(["[*] Tải gói dữ liệu từ máy chủ: [\(name)]..."])

                APIService.shared.downloadFile(slot: slotKey, key: self.key) { [weak self] success, err, data in
                    guard let self = self else { group.leave(); return }
                    if success, let d = data {
                        do {
                            if slotKey == "asset_indexer" {
                                let paths = try FileReplacer.shared.injectAssetIndexer(data: d, bundleId: self.selectedBundleId)
                                term.queueLogs([
                                    "[+] Patching assetindexer.U6Zffc4YIR3DslNj3cXvYGAqz58~3D...",
                                    "[✓] Đã nạp thành công \(paths.count) vị trí asset bundle!"
                                ])
                            } else if slotKey == "cache_res" {
                                let paths = try FileReplacer.shared.injectCacheRes(data: d, bundleId: self.selectedBundleId)
                                term.queueLogs([
                                    "[+] Patching cache_res.GkLlYqzsX4AtTdE55sDMRh9sJOI~3D...",
                                    "[✓] Đã nạp thành công \(paths.count) vị trí cache resource!"
                                ])
                            } else {
                                let dest = try FileReplacer.shared.injectFile(data: d, bundleId: self.selectedBundleId, relativePath: targetPath)
                                term.queueLogs(["[✓] Ghi đè thành công: \((dest as NSString).lastPathComponent)"])
                            }
                        } catch {
                            term.queueLogs(["[!] Lỗi ghi file: \(error.localizedDescription)"])
                        }
                    } else {
                        term.queueLogs(["[!] Lỗi tải file: \(err ?? "Không tải được file")"])
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            term.queueLogs([
                "==================================================",
                "[✓] HOÀN TẤT NẠP TẤT CẢ FILE THÀNH CÔNG 100%!",
                "[*] Đang chuẩn bị khởi chạy game..."
            ])
            term.onFinished = { [weak self] in
                guard let self = self else { return }
                _ = FileReplacer.shared.launchGame(bundleId: self.selectedBundleId)
            }
        }
    }



    @objc private func handleInstallDNS() {
        let mobileconfigUrlStr = "\(APIService.shared.baseURL)/api.php?action=mobileconfig"
        if let url = URL(string: mobileconfigUrlStr) {
            UIApplication.shared.open(url)
        }
    }

    @objc private func handleResetGuest() {
        let ok = FileReplacer.shared.resetGuestAccount(bundleId: selectedBundleId)
        let alert = UIAlertController(
            title: ok ? "Thành công" : "Thông báo",
            message: ok ? "Đã dọn dẹp sạch định danh tài khoản khách! Khi mở game sẽ tạo tài khoản Guest mới hoàn toàn." : "Không tìm thấy dữ liệu guest để xóa.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func handleSelectIcon(_ sender: UIButton) {
        let iconNames = ["calculator", "camera", "capcut", "chatgpt", "facebook", "instagram", "tiktok", "whatsapp", "youtube"]
        guard sender.tag < iconNames.count else { return }
        let selectedIcon = iconNames[sender.tag]

        if UIApplication.shared.supportsAlternateIcons {
            UIApplication.shared.setAlternateIconName(selectedIcon) { error in
                if let err = error {
                    print("Lỗi đổi icon: \(err.localizedDescription)")
                }
            }
        }
    }

    @objc private func handleLogout() {
        countdownTimer?.invalidate()
        dismiss(animated: true)
    }

    private func startCountdown() {
        guard let exp = licenseInfo["expires_at"] as? TimeInterval else { return }
        updateCountdownLabel(exp: exp)

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdownLabel(exp: exp)
        }
    }

    private func updateCountdownLabel(exp: TimeInterval) {
        let diff = exp - Date().timeIntervalSince1970
        if diff <= 0 {
            countdownLabel.textColor = Theme.danger
            countdownLabel.text = "HẠN DÙNG: ĐÃ HẾT HẠN"
        } else {
            let days = Int(diff) / 86400
            let hours = (Int(diff) % 86400) / 3600
            let minutes = (Int(diff) % 3600) / 60
            let seconds = Int(diff) % 60
            countdownLabel.textColor = Theme.success
            countdownLabel.text = String(format: "HẠN DÙNG: %02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
        }
    }

    deinit {
        countdownTimer?.invalidate()
    }
}
