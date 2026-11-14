import UIKit

public final class LoginViewController: UIViewController {

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let hwidLabel = UILabel()
    private let keyTextField = UITextField()
    private let activateButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkMaintenanceOnLaunch()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupUI() {
        view.backgroundColor = Theme.bg

        // Glow radial effect simulation
        let glowView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 260))
        glowView.backgroundColor = Theme.accentDim
        glowView.layer.cornerRadius = 130
        glowView.clipsToBounds = true
        glowView.alpha = 0.5
        glowView.center = CGPoint(x: view.bounds.width / 2, y: 140)
        view.addSubview(glowView)

        // Logo
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "logo.png") ?? UIImage(systemName: "bolt.shield.fill")
        logoImageView.tintColor = Theme.accentLight
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.cornerRadius = 24
        logoImageView.clipsToBounds = true
        logoImageView.layer.borderColor = Theme.cardStroke.cgColor
        logoImageView.layer.borderWidth = 1.5
        view.addSubview(logoImageView)

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ZevCheatiOS"
        titleLabel.font = .systemFont(ofSize: 26, weight: .heavy)
        titleLabel.textColor = Theme.text
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Tactical Container Injector · iOS 17 - 18+"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = Theme.textSub
        subtitleLabel.textAlignment = .center
        view.addSubview(subtitleLabel)

        // HWID Label
        hwidLabel.translatesAutoresizingMaskIntoConstraints = false
        hwidLabel.text = "HWID: \(APIService.shared.deviceHWID)"
        hwidLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        hwidLabel.textColor = Theme.textDim
        hwidLabel.textAlignment = .center
        view.addSubview(hwidLabel)

        // Key Input
        keyTextField.translatesAutoresizingMaskIntoConstraints = false
        keyTextField.placeholder = "Nhập mã Key bản quyền..."
        keyTextField.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        keyTextField.textColor = Theme.text
        keyTextField.backgroundColor = Theme.card
        keyTextField.layer.cornerRadius = 14
        keyTextField.layer.borderWidth = 1.2
        keyTextField.layer.borderColor = Theme.cardStroke.cgColor
        keyTextField.textAlignment = .center
        keyTextField.autocapitalizationType = .allCharacters
        keyTextField.autocorrectionType = .no
        keyTextField.returnKeyType = .done
        // Load saved key if any
        keyTextField.text = UserDefaults.standard.string(forKey: "zev.saved_key")
        view.addSubview(keyTextField)

        // Button Activate
        activateButton.translatesAutoresizingMaskIntoConstraints = false
        activateButton.setTitle("KÍCH HOẠT VIP", for: .normal)
        activateButton.setTitleColor(.white, for: .normal)
        activateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        activateButton.backgroundColor = Theme.accentGlow
        activateButton.layer.cornerRadius = 14
        activateButton.layer.shadowColor = Theme.accentGlow.cgColor
        activateButton.layer.shadowOpacity = 0.5
        activateButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        activateButton.layer.shadowRadius = 12
        activateButton.addTarget(self, action: #selector(handleActivate), for: .touchUpInside)
        view.addSubview(activateButton)

        // Status Label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statusLabel.textColor = Theme.danger
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 2
        statusLabel.isHidden = true
        view.addSubview(statusLabel)

        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activateButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.widthAnchor.constraint(equalToConstant: 96),
            logoImageView.heightAnchor.constraint(equalToConstant: 96),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            hwidLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            hwidLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hwidLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            keyTextField.topAnchor.constraint(equalTo: hwidLabel.bottomAnchor, constant: 36),
            keyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            keyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            keyTextField.heightAnchor.constraint(equalToConstant: 50),

            activateButton.topAnchor.constraint(equalTo: keyTextField.bottomAnchor, constant: 18),
            activateButton.leadingAnchor.constraint(equalTo: keyTextField.leadingAnchor),
            activateButton.trailingAnchor.constraint(equalTo: keyTextField.trailingAnchor),
            activateButton.heightAnchor.constraint(equalToConstant: 50),

            activityIndicator.centerYAnchor.constraint(equalTo: activateButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: activateButton.trailingAnchor, constant: -20),

            statusLabel.topAnchor.constraint(equalTo: activateButton.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: keyTextField.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: keyTextField.trailingAnchor)
        ])
    }

    private func checkMaintenanceOnLaunch() {
        APIService.shared.checkMaintenance { [weak self] isM, msg in
            DispatchQueue.main.async {
                if isM {
                    self?.statusLabel.text = msg
                    self?.statusLabel.textColor = Theme.warning
                    self?.statusLabel.isHidden = false
                    self?.activateButton.isEnabled = false
                    self?.activateButton.alpha = 0.5
                }
            }
        }
    }

    @objc private func handleActivate() {
        guard let key = keyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !key.isEmpty else {
            showError("Vui lòng nhập mã Key bản quyền!")
            return
        }

        view.endEditing(true)
        setLoading(true)
        statusLabel.isHidden = true

        APIService.shared.validateKey(key) { [weak self] valid, msg, info in
            DispatchQueue.main.async {
                self?.setLoading(false)
                if valid {
                    UserDefaults.standard.set(key, forKey: "zev.saved_key")
                    let mainVC = MainViewController(key: key, licenseInfo: info ?? [:])
                    mainVC.modalPresentationStyle = .fullScreen
                    self?.present(mainVC, animated: true)
                } else {
                    self?.showError(msg)
                }
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        activateButton.isEnabled = !loading
        activateButton.setTitle(loading ? "ĐANG KIỂM TRA..." : "KÍCH HOẠT VIP", for: .normal)
        if loading { activityIndicator.startAnimating() } else { activityIndicator.stopAnimating() }
    }

    private func showError(_ text: String) {
        statusLabel.text = text
        statusLabel.textColor = Theme.danger
        statusLabel.isHidden = false
    }
}
