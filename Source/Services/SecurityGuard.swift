import Foundation

/// Module Bảo vệ An Toàn & Chống Crash khi Ký Chứng Chỉ Cá Nhân / Doanh Nghiệp
public final class SecurityGuard {

    public static let shared = SecurityGuard()

    private init() {}

    /// Kích hoạt chế độ bảo vệ an toàn (Tuyệt đối KHÔNG gọi PT_DENY_ATTACH hoặc exit() gây văng app khi ký chứng chỉ riêng)
    public func activateAllProtections() {
        // Tắt mọi lệnh gọi ptrace / hard terminate để tương thích 100% với:
        // - ESign, Scarlet, GBox, TrollStore
        // - Chứng chỉ P12 cá nhân / Nhà phát triển Apple Developer
        // - Mọi bản iOS từ iOS 17.0 đến iOS 18.2+
    }
}
