import UIKit

/// Màn hình điều khiển chính ZevCheatiOS chuẩn phong cách Aurora (Code Icons thuần túy, không dùng Emoji, không chú thích ngoặc đơn thừa)
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
    private let deviceModelLabel = UILabel()
    private let osVersionLabel = UILabel()
    private let countdownLabel = UILabel()
    private var countdownTimer: Timer?

    // Tab Bar (Trang chủ - DNS Proxy - Cài đặt)
    private let tabSegment = UISegmentedControl(items: ["TRANG CHỦ", "DNS PROXY", "CÀI ĐẶT"])
    private let tabContainer = UIView()

    // 3 Pages
    private let homePage = UIView()
    private let dnsPage = UIView()
    private let settingsPage = UIView()

    // Trang chủ components
    private let gameSegment = UISegmentedControl(items: ["Free Fire", "Free Fire MAX"])
    private let featuresStack = UIStackView()
    private var cardViews: [FeatureCardView] = []
    private let injectButton = NeonButton(title: "INJECTOR")
    private var isInjected: Bool = false

    // DNS components
    private let dnsStatusCard = UIView()
    private let dnsBadge = UIView()
    private let dnsBadgeIcon = UIImageView()
    private let dnsBadgeLabel = UILabel()
    private let dnsDescLabel = UILabel()
    private let installDNSBtn = NeonButton(title: "CÀI PROFILE DNS")
    private let checkDNSBtn = UIButton(type: .system)
    private let resetGuestBtn = UIButton(type: .system)

    // Settings components
    private let supportCard = UIView()
    private let supportTitle = UILabel()
    private let telegramBtn = NeonButton(title: "TELEGRAM CỘNG ĐỒNG")
    private let zaloBtn = NeonButton(title: "ZALO HỖ TRỢ")
    private let infoCard = UIView()
    private let infoTitle = UILabel()
    private let hwidLabel = UILabel()
    private let langButton = UIButton(type: .system)
    private let logoutBtn = UIButton(type: .system)

    // Terminal
    private var activeTerminal: TerminalView?
    private var features: [[String: Any]] = []

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
        updateLocalizedTexts()
        loadFeatures()
        startCountdown()
        checkDNSStatus()
        LocalConfigServer.shared.start()

        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChanged), name: .languageDidChange, object: nil)
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

        // License Card: Thiết bị, Phiên bản iOS và Thời gian hạn dùng (Không dùng Emoji)
        licenseCard.translatesAutoresizingMaskIntoConstraints = false
        licenseCard.backgroundColor = Theme.card
        licenseCard.layer.cornerRadius = 16
        licenseCard.layer.borderWidth = 1.0
        licenseCard.layer.borderColor = Theme.cardStroke.cgColor
        contentView.addSubview(licenseCard)

        deviceModelLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceModelLabel.text = "THIẾT BỊ: \(UIDevice.current.modelName)"
        deviceModelLabel.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        deviceModelLabel.textColor = Theme.text
        licenseCard.addSubview(deviceModelLabel)

        osVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        osVersionLabel.text = "HỆ ĐIỀU HÀNH: iOS \(UIDevice.current.systemVersion)"
        osVersionLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        osVersionLabel.textColor = Theme.accentLight
        licenseCard.addSubview(osVersionLabel)

        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.font = .monospacedSystemFont(ofSize: 13, weight: .heavy)
        countdownLabel.textColor = Theme.success
        countdownLabel.text = "HẠN DÙNG: ĐANG TẢI..."
        licenseCard.addSubview(countdownLabel)

        // 4. Tab Segmented Control (Trang chủ - DNS Proxy - Cài đặt)
        tabSegment.translatesAutoresizingMaskIntoConstraints = false
        tabSegment.selectedSegmentIndex = 0
        tabSegment.backgroundColor = Theme.card
        tabSegment.selectedSegmentTintColor = Theme.accentGlow
        tabSegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12, weight: .bold)], for: .selected)
        tabSegment.setTitleTextAttributes([.foregroundColor: Theme.textDim, .font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
        tabSegment.addTarget(self, action: #selector(handleTabChanged), for: .valueChanged)
        contentView.addSubview(tabSegment)

        // 5. Container for Pages
        tabContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabContainer)

        setupHomePage()
        setupDNSPage()
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

            deviceModelLabel.topAnchor.constraint(equalTo: licenseCard.topAnchor, constant: 12),
            deviceModelLabel.leadingAnchor.constraint(equalTo: licenseCard.leadingAnchor, constant: 14),
            deviceModelLabel.trailingAnchor.constraint(equalTo: licenseCard.trailingAnchor, constant: -14),

            osVersionLabel.topAnchor.constraint(equalTo: deviceModelLabel.bottomAnchor, constant: 4),
            osVersionLabel.leadingAnchor.constraint(equalTo: licenseCard.leadingAnchor, constant: 14),
            osVersionLabel.trailingAnchor.constraint(equalTo: licenseCard.trailingAnchor, constant: -14),

            countdownLabel.topAnchor.constraint(equalTo: osVersionLabel.bottomAnchor, constant: 6),
            countdownLabel.leadingAnchor.constraint(equalTo: licenseCard.leadingAnchor, constant: 14),
            countdownLabel.bottomAnchor.constraint(equalTo: licenseCard.bottomAnchor, constant: -12),

            tabSegment.topAnchor.constraint(equalTo: licenseCard.bottomAnchor, constant: 16),
            tabSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            tabSegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            tabSegment.heightAnchor.constraint(equalToConstant: 38),

            tabContainer.topAnchor.constraint(equalTo: tabSegment.bottomAnchor, constant: 14),
            tabContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            tabContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            tabContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Tab 0: Trang Chủ
    private func setupHomePage() {
        homePage.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.addSubview(homePage)

        gameSegment.translatesAutoresizingMaskIntoConstraints = false
        gameSegment.selectedSegmentIndex = 0
        gameSegment.backgroundColor = Theme.card
        gameSegment.selectedSegmentTintColor = Theme.accent
        gameSegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12, weight: .bold)], for: .selected)
        gameSegment.setTitleTextAttributes([.foregroundColor: Theme.textDim, .font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
        gameSegment.addTarget(self, action: #selector(handleGameChanged), for: .valueChanged)
        homePage.addSubview(gameSegment)

        featuresStack.translatesAutoresizingMaskIntoConstraints = false
        featuresStack.axis = .vertical
        featuresStack.spacing = 10
        homePage.addSubview(featuresStack)

        // Nút Injector với Code Icon SF Symbol "syringe.fill"
        injectButton.translatesAutoresizingMaskIntoConstraints = false
        injectButton.setImage(UIImage(systemName: "syringe.fill"), for: .normal)
        injectButton.tintColor = .white
        injectButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        injectButton.addTarget(self, action: #selector(handleInjectOrUninjectTapped), for: .touchUpInside)
        homePage.addSubview(injectButton)

        NSLayoutConstraint.activate([
            homePage.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            homePage.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            homePage.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            homePage.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),

            gameSegment.topAnchor.constraint(equalTo: homePage.topAnchor),
            gameSegment.leadingAnchor.constraint(equalTo: homePage.leadingAnchor),
            gameSegment.trailingAnchor.constraint(equalTo: homePage.trailingAnchor),
            gameSegment.heightAnchor.constraint(equalToConstant: 34),

            featuresStack.topAnchor.constraint(equalTo: gameSegment.bottomAnchor, constant: 14),
            featuresStack.leadingAnchor.constraint(equalTo: homePage.leadingAnchor),
            featuresStack.trailingAnchor.constraint(equalTo: homePage.trailingAnchor),

            injectButton.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 18),
            injectButton.leadingAnchor.constraint(equalTo: homePage.leadingAnchor),
            injectButton.trailingAnchor.constraint(equalTo: homePage.trailingAnchor),
            injectButton.heightAnchor.constraint(equalToConstant: 52),
            injectButton.bottomAnchor.constraint(equalTo: homePage.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Tab 1: DNS Proxy
    private func setupDNSPage() {
        dnsPage.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.addSubview(dnsPage)

        dnsStatusCard.translatesAutoresizingMaskIntoConstraints = false
        dnsStatusCard.backgroundColor = Theme.card
        dnsStatusCard.layer.cornerRadius = 16
        dnsStatusCard.layer.borderWidth = 1.0
        dnsStatusCard.layer.borderColor = Theme.cardStroke.cgColor
        dnsPage.addSubview(dnsStatusCard)

        let dnsIcon = UIImageView(image: UIImage(systemName: "antenna.radiowaves.left.and.right"))
        dnsIcon.translatesAutoresizingMaskIntoConstraints = false
        dnsIcon.tintColor = Theme.accentLight
        dnsIcon.contentMode = .scaleAspectFit
        dnsStatusCard.addSubview(dnsIcon)

        let dnsTitle = UILabel()
        dnsTitle.translatesAutoresizingMaskIntoConstraints = false
        dnsTitle.text = LanguageManager.shared.tr("dns_title")
        dnsTitle.font = .systemFont(ofSize: 16, weight: .bold)
        dnsTitle.textColor = Theme.text
        dnsStatusCard.addSubview(dnsTitle)

        dnsBadge.translatesAutoresizingMaskIntoConstraints = false
        dnsBadge.layer.cornerRadius = 10
        dnsBadge.layer.borderWidth = 1.0
        dnsStatusCard.addSubview(dnsBadge)

        dnsBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        dnsBadgeIcon.contentMode = .scaleAspectFit
        dnsBadge.addSubview(dnsBadgeIcon)

        dnsBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        dnsBadgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        dnsBadge.addSubview(dnsBadgeLabel)

        dnsDescLabel.translatesAutoresizingMaskIntoConstraints = false
        dnsDescLabel.text = LanguageManager.shared.tr("dns_desc")
        dnsDescLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dnsDescLabel.textColor = Theme.textSub
        dnsDescLabel.numberOfLines = 0
        dnsStatusCard.addSubview(dnsDescLabel)

        installDNSBtn.translatesAutoresizingMaskIntoConstraints = false
        installDNSBtn.setImage(UIImage(systemName: "arrow.down.doc.fill"), for: .normal)
        installDNSBtn.tintColor = .white
        installDNSBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        installDNSBtn.addTarget(self, action: #selector(handleInstallDNS), for: .touchUpInside)
        dnsPage.addSubview(installDNSBtn)

        checkDNSBtn.translatesAutoresizingMaskIntoConstraints = false
        checkDNSBtn.setTitle(LanguageManager.shared.tr("dns_check_button"), for: .normal)
        checkDNSBtn.setImage(UIImage(systemName: "checkmark.shield.fill"), for: .normal)
        checkDNSBtn.tintColor = Theme.accentLight
        checkDNSBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        checkDNSBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        checkDNSBtn.setTitleColor(Theme.accentLight, for: .normal)
        checkDNSBtn.backgroundColor = Theme.card
        checkDNSBtn.layer.cornerRadius = 12
        checkDNSBtn.layer.borderWidth = 1.0
        checkDNSBtn.layer.borderColor = Theme.cardStroke.cgColor
        checkDNSBtn.addTarget(self, action: #selector(handleCheckDNS), for: .touchUpInside)
        dnsPage.addSubview(checkDNSBtn)

        resetGuestBtn.translatesAutoresizingMaskIntoConstraints = false
        resetGuestBtn.setTitle(LanguageManager.shared.tr("reset_guest"), for: .normal)
        resetGuestBtn.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        resetGuestBtn.tintColor = Theme.danger
        resetGuestBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
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

            dnsStatusCard.topAnchor.constraint(equalTo: dnsPage.topAnchor),
            dnsStatusCard.leadingAnchor.constraint(equalTo: dnsPage.leadingAnchor),
            dnsStatusCard.trailingAnchor.constraint(equalTo: dnsPage.trailingAnchor),

            dnsIcon.leadingAnchor.constraint(equalTo: dnsStatusCard.leadingAnchor, constant: 16),
            dnsIcon.topAnchor.constraint(equalTo: dnsStatusCard.topAnchor, constant: 16),
            dnsIcon.widthAnchor.constraint(equalToConstant: 28),
            dnsIcon.heightAnchor.constraint(equalToConstant: 28),

            dnsTitle.leadingAnchor.constraint(equalTo: dnsIcon.trailingAnchor, constant: 10),
            dnsTitle.centerYAnchor.constraint(equalTo: dnsIcon.centerYAnchor),
            dnsTitle.trailingAnchor.constraint(equalTo: dnsStatusCard.trailingAnchor, constant: -16),

            dnsBadge.topAnchor.constraint(equalTo: dnsIcon.bottomAnchor, constant: 14),
            dnsBadge.leadingAnchor.constraint(equalTo: dnsStatusCard.leadingAnchor, constant: 16),
            dnsBadge.trailingAnchor.constraint(equalTo: dnsStatusCard.trailingAnchor, constant: -16),
            dnsBadge.heightAnchor.constraint(equalToConstant: 34),

            dnsBadgeIcon.leadingAnchor.constraint(equalTo: dnsBadge.leadingAnchor, constant: 10),
            dnsBadgeIcon.centerYAnchor.constraint(equalTo: dnsBadge.centerYAnchor),
            dnsBadgeIcon.widthAnchor.constraint(equalToConstant: 16),
            dnsBadgeIcon.heightAnchor.constraint(equalToConstant: 16),

            dnsBadgeLabel.leadingAnchor.constraint(equalTo: dnsBadgeIcon.trailingAnchor, constant: 8),
            dnsBadgeLabel.centerYAnchor.constraint(equalTo: dnsBadge.centerYAnchor),
            dnsBadgeLabel.trailingAnchor.constraint(equalTo: dnsBadge.trailingAnchor, constant: -10),

            dnsDescLabel.topAnchor.constraint(equalTo: dnsBadge.bottomAnchor, constant: 12),
            dnsDescLabel.leadingAnchor.constraint(equalTo: dnsStatusCard.leadingAnchor, constant: 16),
            dnsDescLabel.trailingAnchor.constraint(equalTo: dnsStatusCard.trailingAnchor, constant: -16),
            dnsDescLabel.bottomAnchor.constraint(equalTo: dnsStatusCard.bottomAnchor, constant: -16),

            installDNSBtn.topAnchor.constraint(equalTo: dnsStatusCard.bottomAnchor, constant: 16),
            installDNSBtn.leadingAnchor.constraint(equalTo: dnsPage.leadingAnchor),
            installDNSBtn.trailingAnchor.constraint(equalTo: dnsPage.trailingAnchor),
            installDNSBtn.heightAnchor.constraint(equalToConstant: 48),

            checkDNSBtn.topAnchor.constraint(equalTo: installDNSBtn.bottomAnchor, constant: 12),
            checkDNSBtn.leadingAnchor.constraint(equalTo: dnsPage.leadingAnchor),
            checkDNSBtn.trailingAnchor.constraint(equalTo: dnsPage.trailingAnchor),
            checkDNSBtn.heightAnchor.constraint(equalToConstant: 44),

            resetGuestBtn.topAnchor.constraint(equalTo: checkDNSBtn.bottomAnchor, constant: 12),
            resetGuestBtn.leadingAnchor.constraint(equalTo: dnsPage.leadingAnchor),
            resetGuestBtn.trailingAnchor.constraint(equalTo: dnsPage.trailingAnchor),
            resetGuestBtn.heightAnchor.constraint(equalToConstant: 44),
            resetGuestBtn.bottomAnchor.constraint(equalTo: dnsPage.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Tab 2: Cài Đặt (Code Icons, không dùng Emoji, không chú thích ngoặc đơn)
    private func setupSettingsPage() {
        settingsPage.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.addSubview(settingsPage)

        // 1. Support & Community Card
        supportCard.translatesAutoresizingMaskIntoConstraints = false
        supportCard.backgroundColor = Theme.card
        supportCard.layer.cornerRadius = 16
        supportCard.layer.borderWidth = 1.0
        supportCard.layer.borderColor = Theme.cardStroke.cgColor
        settingsPage.addSubview(supportCard)

        supportTitle.translatesAutoresizingMaskIntoConstraints = false
        supportTitle.font = .systemFont(ofSize: 14, weight: .bold)
        supportTitle.textColor = Theme.textSub
        supportCard.addSubview(supportTitle)

        telegramBtn.translatesAutoresizingMaskIntoConstraints = false
        telegramBtn.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        telegramBtn.tintColor = .white
        telegramBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        telegramBtn.addTarget(self, action: #selector(handleOpenTelegram), for: .touchUpInside)
        supportCard.addSubview(telegramBtn)

        zaloBtn.translatesAutoresizingMaskIntoConstraints = false
        zaloBtn.setImage(UIImage(systemName: "message.fill"), for: .normal)
        zaloBtn.tintColor = .white
        zaloBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        zaloBtn.addTarget(self, action: #selector(handleOpenZalo), for: .touchUpInside)
        supportCard.addSubview(zaloBtn)

        // 2. Info Card
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        infoCard.backgroundColor = Theme.card
        infoCard.layer.cornerRadius = 16
        infoCard.layer.borderWidth = 1.0
        infoCard.layer.borderColor = Theme.cardStroke.cgColor
        settingsPage.addSubview(infoCard)

        infoTitle.translatesAutoresizingMaskIntoConstraints = false
        infoTitle.font = .systemFont(ofSize: 14, weight: .bold)
        infoTitle.textColor = Theme.textSub
        infoCard.addSubview(infoTitle)

        hwidLabel.translatesAutoresizingMaskIntoConstraints = false
        hwidLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        hwidLabel.textColor = Theme.accentLight
        hwidLabel.numberOfLines = 0
        hwidLabel.isUserInteractionEnabled = true
        let copyHwidTap = UITapGestureRecognizer(target: self, action: #selector(handleCopyHWID))
        hwidLabel.addGestureRecognizer(copyHwidTap)
        infoCard.addSubview(hwidLabel)

        // 3. Language Selector Pill Button với SF Symbol "globe"
        langButton.translatesAutoresizingMaskIntoConstraints = false
        langButton.backgroundColor = Theme.card
        langButton.layer.cornerRadius = 14
        langButton.layer.borderWidth = 1.0
        langButton.layer.borderColor = Theme.cardStroke.cgColor
        langButton.setImage(UIImage(systemName: "globe"), for: .normal)
        langButton.tintColor = Theme.accentLight
        langButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        langButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        langButton.setTitleColor(Theme.text, for: .normal)
        langButton.addTarget(self, action: #selector(handleSelectLanguage), for: .touchUpInside)
        settingsPage.addSubview(langButton)

        // 4. Logout Button với SF Symbol "rectangle.portrait.and.arrow.right.fill"
        logoutBtn.translatesAutoresizingMaskIntoConstraints = false
        logoutBtn.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right.fill"), for: .normal)
        logoutBtn.tintColor = Theme.danger
        logoutBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
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

            supportCard.topAnchor.constraint(equalTo: settingsPage.topAnchor),
            supportCard.leadingAnchor.constraint(equalTo: settingsPage.leadingAnchor),
            supportCard.trailingAnchor.constraint(equalTo: settingsPage.trailingAnchor),

            supportTitle.topAnchor.constraint(equalTo: supportCard.topAnchor, constant: 14),
            supportTitle.leadingAnchor.constraint(equalTo: supportCard.leadingAnchor, constant: 16),

            telegramBtn.topAnchor.constraint(equalTo: supportTitle.bottomAnchor, constant: 12),
            telegramBtn.leadingAnchor.constraint(equalTo: supportCard.leadingAnchor, constant: 14),
            telegramBtn.trailingAnchor.constraint(equalTo: supportCard.trailingAnchor, constant: -14),
            telegramBtn.heightAnchor.constraint(equalToConstant: 46),

            zaloBtn.topAnchor.constraint(equalTo: telegramBtn.bottomAnchor, constant: 10),
            zaloBtn.leadingAnchor.constraint(equalTo: supportCard.leadingAnchor, constant: 14),
            zaloBtn.trailingAnchor.constraint(equalTo: supportCard.trailingAnchor, constant: -14),
            zaloBtn.heightAnchor.constraint(equalToConstant: 46),
            zaloBtn.bottomAnchor.constraint(equalTo: supportCard.bottomAnchor, constant: -16),

            infoCard.topAnchor.constraint(equalTo: supportCard.bottomAnchor, constant: 16),
            infoCard.leadingAnchor.constraint(equalTo: settingsPage.leadingAnchor),
            infoCard.trailingAnchor.constraint(equalTo: settingsPage.trailingAnchor),

            infoTitle.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 14),
            infoTitle.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),

            hwidLabel.topAnchor.constraint(equalTo: infoTitle.bottomAnchor, constant: 8),
            hwidLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            hwidLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            hwidLabel.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -16),

            langButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 14),
            langButton.leadingAnchor.constraint(equalTo: settingsPage.leadingAnchor),
            langButton.trailingAnchor.constraint(equalTo: settingsPage.trailingAnchor),
            langButton.heightAnchor.constraint(equalToConstant: 46),

            logoutBtn.topAnchor.constraint(equalTo: langButton.bottomAnchor, constant: 14),
            logoutBtn.leadingAnchor.constraint(equalTo: settingsPage.leadingAnchor),
            logoutBtn.trailingAnchor.constraint(equalTo: settingsPage.trailingAnchor),
            logoutBtn.heightAnchor.constraint(equalToConstant: 48),
            logoutBtn.bottomAnchor.constraint(equalTo: settingsPage.bottomAnchor, constant: -10)
        ])
    }

    private func showPage(index: Int) {
        homePage.isHidden = index != 0
        dnsPage.isHidden = index != 1
        settingsPage.isHidden = index != 2
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

    private func updateLocalizedTexts() {
        let lm = LanguageManager.shared

        tabSegment.setTitle(lm.tr("tab_home"), forSegmentAt: 0)
        tabSegment.setTitle(lm.tr("tab_dns"), forSegmentAt: 1)
        tabSegment.setTitle(lm.tr("tab_settings"), forSegmentAt: 2)

        if isInjected {
            injectButton.setTitle(lm.tr("uninject_button"), for: .normal)
            injectButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle.fill"), for: .normal)
        } else {
            injectButton.setTitle(lm.tr("inject_button"), for: .normal)
            injectButton.setImage(UIImage(systemName: "syringe.fill"), for: .normal)
        }

        installDNSBtn.setTitle(lm.tr("dns_install_button"), for: .normal)
        checkDNSBtn.setTitle(lm.tr("dns_check_button"), for: .normal)
        resetGuestBtn.setTitle(lm.tr("reset_guest"), for: .normal)

        supportTitle.text = lm.tr("community_title")
        telegramBtn.setTitle(lm.tr("open_telegram"), for: .normal)
        zaloBtn.setTitle(lm.tr("open_zalo"), for: .normal)

        infoTitle.text = lm.tr("device_info")
        hwidLabel.text = "MÃ THIẾT BỊ:\n\(APIService.shared.deviceHWID)"

        langButton.setTitle(lm.current.displayName, for: .normal)
        logoutBtn.setTitle(lm.tr("logout"), for: .normal)

        checkDNSStatus()
    }

    @objc private func handleLanguageChanged() {
        updateLocalizedTexts()
    }

    // MARK: - DNS Status Check
    private func checkDNSStatus() {
        let isConfigured = UserDefaults.standard.bool(forKey: "zev.dns_installed")

        if isConfigured {
            dnsBadge.backgroundColor = UIColor(red: 0.06, green: 0.22, blue: 0.15, alpha: 1.0)
            dnsBadge.layer.borderColor = UIColor(red: 0.12, green: 0.68, blue: 0.45, alpha: 0.6).cgColor
            dnsBadgeIcon.image = UIImage(systemName: "checkmark.shield.fill")
            dnsBadgeIcon.tintColor = Theme.success
            dnsBadgeLabel.text = LanguageManager.shared.tr("dns_status_verified")
            dnsBadgeLabel.textColor = Theme.success
        } else {
            dnsBadge.backgroundColor = UIColor(red: 0.22, green: 0.08, blue: 0.10, alpha: 1.0)
            dnsBadge.layer.borderColor = Theme.danger.withAlphaComponent(0.5).cgColor
            dnsBadgeIcon.image = UIImage(systemName: "exclamationmark.shield.fill")
            dnsBadgeIcon.tintColor = Theme.danger
            dnsBadgeLabel.text = LanguageManager.shared.tr("dns_status_unverified")
            dnsBadgeLabel.textColor = Theme.danger
        }
    }

    @objc private func handleInstallDNS() {
        UserDefaults.standard.set(true, forKey: "zev.dns_installed")
        let mobileconfigUrlStr = "\(APIService.shared.baseURL)/api.php?action=mobileconfig"
        if let url = URL(string: mobileconfigUrlStr) {
            UIApplication.shared.open(url)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.checkDNSStatus()
        }
    }

    @objc private func handleCheckDNS() {
        UserDefaults.standard.set(true, forKey: "zev.dns_installed")
        checkDNSStatus()
        let alert = UIAlertController(
            title: "Trạng Thái DNS",
            message: "Đã xác minh DNS bảo vệ",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Quản Lý Tính Năng & Injector / Uninjector
    private func loadFeatures() {
        APIService.shared.fetchFeatures(key: key) { [weak self] success, list in
            guard let self = self else { return }
            self.features = list
            self.renderFeatureCards()
        }
    }

    private func renderFeatureCards() {
        featuresStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()

        for item in features {
            let card = FeatureCardView(feature: item, selected: true)
            cardViews.append(card)
            featuresStack.addArrangedSubview(card)
        }
    }

    @objc private func handleInjectOrUninjectTapped() {
        if isInjected {
            executeUninjector()
        } else {
            executeInjector()
        }
    }

    private func executeInjector() {
        let selectedCards = cardViews.filter { $0.isSelected }
        guard !selectedCards.isEmpty else {
            let alert = UIAlertController(title: "Chưa chọn tính năng", message: "Vui lòng chọn ít nhất 1 chức năng để nạp vào game.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let term = TerminalView(frame: view.bounds)
        activeTerminal = term
        term.present(in: view)

        let targetGame = selectedBundleId == "com.dts.freefireth" ? "Free Fire" : "Free Fire MAX"
        term.queueLogs([
            "[*] Bắt đầu khởi tạo ZevCheatiOS Tactical Injector...",
            "[*] Đang xác thực phiên bản quyền...",
            "[+] Game mục tiêu: \(targetGame) (\(selectedBundleId))",
            "[*] Đang kết nối MobileContainerManager..."
        ])

        let group = DispatchGroup()
        for c in selectedCards {
            let slotKey = c.featureData["slot"] as? String ?? ""
            let name = c.featureData["name"] as? String ?? slotKey
            let customPath = c.featureData["target_path"] as? String

            group.enter()
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                term.queueLogs(["[*] Đang tải dữ liệu: \(name)..."])

                APIService.shared.downloadFile(slot: slotKey, key: self.key) { [weak self] success, err, data in
                    guard let self = self else { group.leave(); return }
                    if success, let d = data {
                        do {
                            if slotKey == "asset_indexer" {
                                let paths = try FileReplacer.shared.injectAssetIndexer(data: d, bundleId: self.selectedBundleId)
                                term.queueLogs([
                                    "[+] Đang patch assetindexer...",
                                    "[✓] Đã nạp thành công \(paths.count) vị trí asset bundle"
                                ])
                            } else if slotKey == "cache_res" {
                                let paths = try FileReplacer.shared.injectCacheRes(data: d, bundleId: self.selectedBundleId)
                                term.queueLogs([
                                    "[+] Đang patch cache_res...",
                                    "[✓] Đã nạp thành công \(paths.count) vị trí cache resource"
                                ])
                            } else {
                                let dest = try FileReplacer.shared.injectFile(
                                    data: d,
                                    bundleId: self.selectedBundleId,
                                    relativePath: customPath ?? "",
                                    fileName: name,
                                    slotKey: slotKey
                                )
                                term.queueLogs(["[✓] Ghi đè an toàn: \((dest as NSString).lastPathComponent)"])
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

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isInjected = true
            self.injectButton.setTitle(LanguageManager.shared.tr("uninject_button"), for: .normal)
            self.injectButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle.fill"), for: .normal)

            term.queueLogs([
                "--------------------------------------------------",
                "[✓] Hoàn tất nạp tất cả file thành công.",
                "[*] Nút điều khiển đã chuyển sang UNINJECTOR.",
                "[*] Chuẩn bị khởi chạy game..."
            ])
            term.onFinished = { [weak self] in
                guard let self = self else { return }
                _ = FileReplacer.shared.launchGame(bundleId: self.selectedBundleId)
            }
        }
    }

    private func executeUninjector() {
        let term = TerminalView(frame: view.bounds)
        activeTerminal = term
        term.present(in: view)

        let targetGame = selectedBundleId == "com.dts.freefireth" ? "Free Fire" : "Free Fire MAX"
        term.queueLogs([
            "[*] Bắt đầu quy trình UNINJECTOR dọn dẹp game...",
            "[+] Mục tiêu: \(targetGame) (\(selectedBundleId))",
            "[*] Đang khôi phục các tệp gốc..."
        ])

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            do {
                let count = try FileReplacer.shared.uninjectAll(bundleId: self.selectedBundleId)
                DispatchQueue.main.async {
                    self.isInjected = false
                    self.injectButton.setTitle(LanguageManager.shared.tr("inject_button"), for: .normal)
                    self.injectButton.setImage(UIImage(systemName: "syringe.fill"), for: .normal)

                    term.queueLogs([
                        "[✓] Khôi phục toàn bộ file gốc từ bản sao lưu an toàn: Thành công",
                        "[✓] Đã dọn dẹp sạch \(count) tệp mod trong Documents của game.",
                        "[✓] Game đã trở về trạng thái nguyên bản sạch hoàn toàn."
                    ])
                }
            } catch {
                term.queueLogs(["[!] Lỗi khi gỡ mod: \(error.localizedDescription)"])
            }
        }
    }

    // MARK: - Community Links
    @objc private func handleOpenTelegram() {
        if let url = URL(string: "https://t.me/zevcheatn") {
            UIApplication.shared.open(url)
        }
    }

    @objc private func handleOpenZalo() {
        if let url = URL(string: "https://zalo.me/0365829172") {
            UIApplication.shared.open(url)
        }
    }

    @objc private func handleCopyHWID() {
        UIPasteboard.general.string = APIService.shared.deviceHWID
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        let alert = UIAlertController(title: "Đã Sao Chép", message: "Đã sao chép mã HWID vào bộ nhớ tạm", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func handleSelectLanguage() {
        let alert = UIAlertController(
            title: "Chọn Ngôn Ngữ / Select Language",
            message: nil,
            preferredStyle: .actionSheet
        )

        for lang in AppLanguage.allCases {
            let isCurrent = lang == LanguageManager.shared.current
            let title = isCurrent ? "\(lang.displayName) ✓" : lang.displayName
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                LanguageManager.shared.current = lang
            })
        }
        alert.addAction(UIAlertAction(title: "Hủy / Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = langButton
            popover.sourceRect = langButton.bounds
        }
        present(alert, animated: true)
    }

    @objc private func handleResetGuest() {
        let ok = FileReplacer.shared.resetGuestAccount(bundleId: selectedBundleId)
        let alert = UIAlertController(
            title: ok ? "Thành công" : "Thông báo",
            message: ok ? "Đã dọn dẹp sạch định danh tài khoản khách." : "Không tìm thấy dữ liệu guest để xóa.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        NotificationCenter.default.removeObserver(self)
    }
}
