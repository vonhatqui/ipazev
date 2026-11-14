import Foundation
import UIKit

public enum AppLanguage: String, CaseIterable {
    case vi = "vi"
    case en = "en"
    case sg = "sg"
    case id = "id"

    public var displayName: String {
        switch self {
        case .vi: return "Tiếng Việt"
        case .en: return "English"
        case .sg: return "Singapore"
        case .id: return "Bahasa Indonesia"
        }
    }

    public var shortTitle: String {
        switch self {
        case .vi: return "Tiếng Việt"
        case .en: return "English"
        case .sg: return "Singapore"
        case .id: return "Indonesia"
        }
    }
}

public final class LanguageManager {
    public static let shared = LanguageManager()
    private let key = "zev.app_language"

    public var current: AppLanguage {
        get {
            if let raw = UserDefaults.standard.string(forKey: key),
               let lang = AppLanguage(rawValue: raw) {
                return lang
            }
            return .vi
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }

    private let strings: [String: [AppLanguage: String]] = [
        "app_title": [
            .vi: "ZevCheatiOS",
            .en: "ZevCheatiOS",
            .sg: "ZevCheatiOS",
            .id: "ZevCheatiOS"
        ],
        "app_subtitle": [
            .vi: "TACTICAL CONTAINER INJECTOR",
            .en: "TACTICAL CONTAINER INJECTOR",
            .sg: "TACTICAL CONTAINER INJECTOR",
            .id: "TACTICAL CONTAINER INJECTOR"
        ],
        "device_model": [
            .vi: "Model Thiết Bị",
            .en: "Device Model",
            .sg: "Device Model",
            .id: "Model Perangkat"
        ],
        "ios_version": [
            .vi: "Phiên Bản iOS",
            .en: "iOS Version",
            .sg: "iOS Version",
            .id: "Versi iOS"
        ],
        "supported": [
            .vi: "Được Hỗ Trợ",
            .en: "Supported",
            .sg: "Supported",
            .id: "Didukung"
        ],
        "verified": [
            .vi: "Đã xác minh",
            .en: "Verified",
            .sg: "Verified",
            .id: "Terverifikasi"
        ],
        "enter_key": [
            .vi: "Nhập Khóa Giấy Phép",
            .en: "Enter License Key",
            .sg: "Enter License Key",
            .id: "Masukkan Kunci Lisensi"
        ],
        "key_placeholder": [
            .vi: "Nhập mã key",
            .en: "Enter license key",
            .sg: "Enter license key",
            .id: "Masukkan kunci lisensi"
        ],
        "paste": [
            .vi: "DÁN",
            .en: "PASTE",
            .sg: "PASTE",
            .id: "TEMPEL"
        ],
        "activate": [
            .vi: "Kích Hoạt",
            .en: "Activate",
            .sg: "Activate",
            .id: "Aktivasi"
        ],
        "tab_home": [
            .vi: "TRANG CHỦ",
            .en: "HOME",
            .sg: "HOME",
            .id: "BERANDA"
        ],
        "tab_dns": [
            .vi: "DNS PROXY",
            .en: "DNS PROXY",
            .sg: "DNS PROXY",
            .id: "DNS PROXY"
        ],
        "tab_settings": [
            .vi: "CÀI ĐẶT",
            .en: "SETTINGS",
            .sg: "SETTINGS",
            .id: "PENGATURAN"
        ],
        "inject_button": [
            .vi: "INJECTOR",
            .en: "INJECTOR",
            .sg: "INJECTOR",
            .id: "INJECTOR"
        ],
        "uninject_button": [
            .vi: "UNINJECTOR",
            .en: "UNINJECTOR",
            .sg: "UNINJECTOR",
            .id: "UNINJECTOR"
        ],
        "dns_title": [
            .vi: "Cấu Hình DoH DNS Chặn Ban",
            .en: "DoH Anti-Ban DNS Configuration",
            .sg: "DoH Anti-Ban DNS Configuration",
            .id: "Konfigurasi DoH DNS Anti-Ban"
        ],
        "dns_desc": [
            .vi: "Định tuyến DNS qua máy chủ bảo vệ để tự động chặn các domain ghi nhận telemetry, báo cáo gian lận và quét chữ ký của Free Fire.",
            .en: "Route DNS through protection server to automatically block telemetry, anti-cheat reporting, and signature scans.",
            .sg: "Route DNS through protection server to automatically block telemetry, anti-cheat reporting, and signature scans.",
            .id: "Rute DNS melalui server proteksi untuk memblokir telemetri, laporan kecurangan, dan pemindaian tanda tangan."
        ],
        "dns_status_verified": [
            .vi: "Đã Xác Minh DNS",
            .en: "DNS Verified",
            .sg: "DNS Verified",
            .id: "DNS Terverifikasi"
        ],
        "dns_status_unverified": [
            .vi: "Chưa Cài Đặt DNS",
            .en: "DNS Not Installed",
            .sg: "DNS Not Installed",
            .id: "DNS Belum Terpasang"
        ],
        "dns_install_button": [
            .vi: "CÀI PROFILE DNS",
            .en: "INSTALL DNS PROFILE",
            .sg: "INSTALL DNS PROFILE",
            .id: "PASANG PROFIL DNS"
        ],
        "dns_check_button": [
            .vi: "KIỂM TRA DNS",
            .en: "CHECK DNS STATUS",
            .sg: "CHECK DNS STATUS",
            .id: "PERIKSA STATUS DNS"
        ],
        "community_title": [
            .vi: "KÊNH HỖ TRỢ",
            .en: "SUPPORT CHANNELS",
            .sg: "SUPPORT CHANNELS",
            .id: "SALURAN DUKUNGAN"
        ],
        "open_telegram": [
            .vi: "TELEGRAM CỘNG ĐỒNG",
            .en: "TELEGRAM COMMUNITY",
            .sg: "TELEGRAM COMMUNITY",
            .id: "KOMUNITAS TELEGRAM"
        ],
        "open_zalo": [
            .vi: "ZALO HỖ TRỢ",
            .en: "ZALO SUPPORT",
            .sg: "ZALO SUPPORT",
            .id: "DUKUNGAN ZALO"
        ],
        "reset_guest": [
            .vi: "XÓA TÀI KHOẢN KHÁCH",
            .en: "RESET GUEST ACCOUNT",
            .sg: "RESET GUEST ACCOUNT",
            .id: "HAPUS AKUN GUEST"
        ],
        "logout": [
            .vi: "ĐĂNG XUẤT",
            .en: "LOGOUT",
            .sg: "LOGOUT",
            .id: "KELUAR"
        ],
        "device_info": [
            .vi: "THÔNG TIN HỆ THỐNG",
            .en: "SYSTEM INFORMATION",
            .sg: "SYSTEM INFORMATION",
            .id: "INFORMASI SISTEM"
        ]
    ]

    public func tr(_ key: String) -> String {
        return strings[key]?[current] ?? strings[key]?[.vi] ?? key
    }
}

public extension Notification.Name {
    static let languageDidChange = Notification.Name("zev.languageDidChange")
}
