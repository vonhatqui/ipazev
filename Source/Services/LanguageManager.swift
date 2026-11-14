import Foundation
import UIKit

public enum AppLanguage: String, CaseIterable {
    case vi = "vi"
    case en = "en"
    case sg = "sg"
    case id = "id"

    public var displayName: String {
        switch self {
        case .vi: return "🇻🇳 Tiếng Việt"
        case .en: return "🇺🇸 English"
        case .sg: return "🇸🇬 Singapore (SG)"
        case .id: return "🇮🇩 Bahasa Indonesia"
        }
    }

    public var shortTitle: String {
        switch self {
        case .vi: return "🌐 Tiếng Việt"
        case .en: return "🌐 English"
        case .sg: return "🌐 Singapore"
        case .id: return "🌐 Indonesia"
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
            .vi: "TACTICAL CONTAINER INJECTOR · VIP",
            .en: "TACTICAL CONTAINER INJECTOR · VIP",
            .sg: "TACTICAL CONTAINER INJECTOR · VIP",
            .id: "TACTICAL CONTAINER INJECTOR · VIP"
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
            .vi: "Nhập mã key VIP của bạn...",
            .en: "Enter your VIP key...",
            .sg: "Enter your VIP key...",
            .id: "Masukkan kunci VIP Anda..."
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
            .vi: "💉 INJECTOR VÀO GAME",
            .en: "💉 INJECT INTO GAME",
            .sg: "💉 INJECT INTO GAME",
            .id: "💉 INJECTOR KE GAME"
        ],
        "uninject_button": [
            .vi: "🔄 UNINJECTOR (XÓA SẠCH MOD/FILE)",
            .en: "🔄 UNINJECTOR (RESTORE CLEAN)",
            .sg: "🔄 UNINJECTOR (RESTORE CLEAN)",
            .id: "🔄 UNINJECTOR (HAPUS BERSIH MOD)"
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
            .vi: "✓ Đã Xác Minh DNS (Đã xác thực bởi ZevCheat iOS)",
            .en: "✓ DNS Verified (Authenticated by ZevCheat iOS)",
            .sg: "✓ DNS Verified (Authenticated by ZevCheat iOS)",
            .id: "✓ DNS Terverifikasi (Diautentikasi oleh ZevCheat iOS)"
        ],
        "dns_status_unverified": [
            .vi: "⚠️ Chưa Cài Đặt DNS Bảo Vệ (Bắt buộc)",
            .en: "⚠️ DNS Protection Not Installed (Required)",
            .sg: "⚠️ DNS Protection Not Installed (Required)",
            .id: "⚠️ Proteksi DNS Belum Terpasang (Wajib)"
        ],
        "dns_install_button": [
            .vi: "📥 CÀI PROFILE DNS (.MOBILECONFIG)",
            .en: "📥 INSTALL DNS PROFILE (.MOBILECONFIG)",
            .sg: "📥 INSTALL DNS PROFILE (.MOBILECONFIG)",
            .id: "📥 PASANG PROFIL DNS (.MOBILECONFIG)"
        ],
        "dns_check_button": [
            .vi: "🔄 KIỂM TRA LẠI TRẠNG THÁI DNS",
            .en: "🔄 RECHECK DNS STATUS",
            .sg: "🔄 RECHECK DNS STATUS",
            .id: "🔄 PERIKSA ULANG STATUS DNS"
        ],
        "community_title": [
            .vi: "CỘNG ĐỒNG & HỖ TRỢ KỸ THUẬT",
            .en: "COMMUNITY & TECHNICAL SUPPORT",
            .sg: "COMMUNITY & TECHNICAL SUPPORT",
            .id: "KOMUNITAS & DUKUNGAN TEKNIS"
        ],
        "open_telegram": [
            .vi: "💬 VÀO TELEGRAM CỘNG ĐỒNG (t.me/zevcheatn)",
            .en: "💬 JOIN TELEGRAM COMMUNITY (t.me/zevcheatn)",
            .sg: "💬 JOIN TELEGRAM COMMUNITY (t.me/zevcheatn)",
            .id: "💬 GABUNG TELEGRAM (t.me/zevcheatn)"
        ],
        "open_zalo": [
            .vi: "💬 CHAT ZALO HỖ TRỢ: 0365829172",
            .en: "💬 CHAT ZALO SUPPORT: 0365829172",
            .sg: "💬 CHAT ZALO SUPPORT: 0365829172",
            .id: "💬 CHAT DUKUNGAN ZALO: 0365829172"
        ],
        "reset_guest": [
            .vi: "🗑️ XÓA DỮ LIỆU TÀI KHOẢN KHÁCH (RESET GUEST)",
            .en: "🗑️ RESET GUEST ACCOUNT DATA",
            .sg: "🗑️ RESET GUEST ACCOUNT DATA",
            .id: "🗑️ HAPUS DATA AKUN GUEST"
        ],
        "logout": [
            .vi: "ĐĂNG XUẤT LICENSE",
            .en: "LOGOUT LICENSE",
            .sg: "LOGOUT LICENSE",
            .id: "KELUAR LISENSI"
        ],
        "device_info": [
            .vi: "THÔNG TIN THIẾT BỊ & PHIÊN BẢN",
            .en: "DEVICE & VERSION INFORMATION",
            .sg: "DEVICE & VERSION INFORMATION",
            .id: "INFORMASI PERANGKAT & VERSI"
        ]
    ]

    public func tr(_ key: String) -> String {
        return strings[key]?[current] ?? strings[key]?[.vi] ?? key
    }
}

public extension Notification.Name {
    static let languageDidChange = Notification.Name("zev.languageDidChange")
}
