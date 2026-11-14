import Foundation

/// Dịch vụ tải và nạp trực tiếp file cache vào thư mục Documents của Free Fire (Chuẩn kiến trúc Aurora Injector)
public final class FileReplacer {

    public static let shared = FileReplacer()
    private let fileManager = FileManager.default

    private init() {}

    /// Đường dẫn thư mục Bundle Assets trong Documents của Free Fire
    private let compulsorySubpath = "Documents/contentcache/Compulsory/ios/gameassetbundles"
    private let avatarSubpath = "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar"

    /// Nạp file nhị phân vào đường dẫn mục tiêu trong Game Container
    /// - Parameters:
    ///   - data: Dữ liệu nhị phân của file tải từ server
    ///   - bundleId: Bundle ID của game (com.dts.freefireth hoặc com.dts.freefiremax)
    ///   - relativePath: Đường dẫn tương đối (VD: Documents/localConfig.json)
    /// - Returns: Đường dẫn file thực tế trên thiết bị
    @discardableResult
    public func injectFile(data: Data, bundleId: String, relativePath: String) throws -> String {
        guard let containerPath = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            throw NSError(domain: "ZevCheatiOS", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Không tìm thấy Sandbox của game (\(bundleId)). Vui lòng mở game ít nhất 1 lần để tạo Documents!"
            ])
        }

        let fullDestPath = (containerPath as NSString).appendingPathComponent(relativePath)
        let parentDir = (fullDestPath as NSString).deletingLastPathComponent

        // Tạo thư mục cha nếu chưa có
        if !fileManager.fileExists(atPath: parentDir) {
            try fileManager.createDirectory(atPath: parentDir, withIntermediateDirectories: true, attributes: nil)
        }

        // Tạo bản backup an toàn nếu file cũ đã tồn tại
        if fileManager.fileExists(atPath: fullDestPath) {
            let backupDir = (containerPath as NSString).appendingPathComponent("Documents/Zev_Backups")
            if !fileManager.fileExists(atPath: backupDir) {
                try? fileManager.createDirectory(atPath: backupDir, withIntermediateDirectories: true, attributes: nil)
            }
            let fileName = (fullDestPath as NSString).lastPathComponent
            let backupPath = (backupDir as NSString).appendingPathComponent("\(fileName).bak")
            try? fileManager.removeItem(atPath: backupPath)
            try? fileManager.copyItem(atPath: fullDestPath, toPath: backupPath)
        }

        // Ghi đè file mới nguyên tử (Atomic write)
        try data.write(to: URL(fileURLWithPath: fullDestPath), options: .atomic)
        return fullDestPath
    }

    /// Nạp trực tiếp file từ máy iPhone vào Documents bằng thuật toán thay thế an toàn của 3105
    @discardableResult
    public func injectLocalFile(sourceURL: URL, bundleId: String, relativePath: String) throws -> String {
        guard let containerPath = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            throw NSError(domain: "ZevCheatiOS", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Không tìm thấy Sandbox của game (\(bundleId)). Vui lòng mở game ít nhất 1 lần để tạo Documents!"
            ])
        }

        let fullDestPath = (containerPath as NSString).appendingPathComponent(relativePath)
        let parentDir = (fullDestPath as NSString).deletingLastPathComponent

        if !fileManager.fileExists(atPath: parentDir) {
            try fileManager.createDirectory(atPath: parentDir, withIntermediateDirectories: true, attributes: nil)
        }

        let targetURL = URL(fileURLWithPath: fullDestPath)
        if fileManager.fileExists(atPath: fullDestPath) {
            _ = try FileReplacementService.replace(target: targetURL, with: sourceURL)
        } else {
            try fileManager.copyItem(at: sourceURL, to: targetURL)
        }
        return fullDestPath
    }

    /// Tự động tìm và ghi đè toàn bộ các biến thể assetindexer (bao gồm assetindexer.U6Zffc4YIR3DslNj3cXvYGAqz58~3D)
    public func injectAssetIndexer(data: Data, bundleId: String) throws -> [String] {
        guard let containerPath = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            throw NSError(domain: "ZevCheatiOS", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Không tìm thấy Sandbox của game (\(bundleId))."
            ])
        }

        var injectedPaths: [String] = []
        let targetDirs = [
            (containerPath as NSString).appendingPathComponent(compulsorySubpath),
            (containerPath as NSString).appendingPathComponent(avatarSubpath)
        ]

        let specificName = "assetindexer.U6Zffc4YIR3DslNj3cXvYGAqz58~3D"

        for dir in targetDirs {
            if !fileManager.fileExists(atPath: dir) {
                try? fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            }

            // Quét tìm tất cả file có tiền tố assetindexer. trong thư mục
            if let files = try? fileManager.contentsOfDirectory(atPath: dir) {
                for f in files where f.hasPrefix("assetindexer.") {
                    let dest = (dir as NSString).appendingPathComponent(f)
                    try? data.write(to: URL(fileURLWithPath: dest), options: .atomic)
                    injectedPaths.append(dest)
                }
            }

            // Luôn đảm bảo file specificName tồn tại
            let specificDest = (dir as NSString).appendingPathComponent(specificName)
            try? data.write(to: URL(fileURLWithPath: specificDest), options: .atomic)
            if !injectedPaths.contains(specificDest) {
                injectedPaths.append(specificDest)
            }
        }

        return injectedPaths
    }

    /// Tự động tìm và ghi đè toàn bộ các biến thể cache_res (bao gồm cache_res.GkLlYqzsX4AtTdE55sDMRh9sJOI~3D)
    public func injectCacheRes(data: Data, bundleId: String) throws -> [String] {
        guard let containerPath = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            throw NSError(domain: "ZevCheatiOS", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Không tìm thấy Sandbox của game (\(bundleId))."
            ])
        }

        var injectedPaths: [String] = []
        let targetDirs = [
            (containerPath as NSString).appendingPathComponent(compulsorySubpath),
            (containerPath as NSString).appendingPathComponent(avatarSubpath)
        ]

        let specificName = "cache_res.GkLlYqzsX4AtTdE55sDMRh9sJOI~3D"

        for dir in targetDirs {
            if !fileManager.fileExists(atPath: dir) {
                try? fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            }

            // Quét tìm tất cả file có tiền tố cache_res. trong thư mục
            if let files = try? fileManager.contentsOfDirectory(atPath: dir) {
                for f in files where f.hasPrefix("cache_res.") {
                    let dest = (dir as NSString).appendingPathComponent(f)
                    try? data.write(to: URL(fileURLWithPath: dest), options: .atomic)
                    injectedPaths.append(dest)
                }
            }

            // Luôn đảm bảo file specificName tồn tại
            let specificDest = (dir as NSString).appendingPathComponent(specificName)
            try? data.write(to: URL(fileURLWithPath: specificDest), options: .atomic)
            if !injectedPaths.contains(specificDest) {
                injectedPaths.append(specificDest)
            }
        }

        return injectedPaths
    }

    /// Reset tài khoản khách (Guest) bằng cách xóa toàn bộ định danh guest
    public func resetGuestAccount(bundleId: String) -> Bool {
        guard let container = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            return false
        }
        let doc = (container as NSString).appendingPathComponent("Documents")
        let guestPaths = [
            (doc as NSString).appendingPathComponent("g_data"),
            (doc as NSString).appendingPathComponent("guest_info"),
            (doc as NSString).appendingPathComponent("app_guest_id.dat"),
            (doc as NSString).appendingPathComponent("reset_guest.flag")
        ]
        for p in guestPaths {
            try? fileManager.removeItem(atPath: p)
        }
        return true
    }

    /// Tự động khởi chạy Game Free Fire sau khi nạp cache xong qua LSApplicationWorkspace
    public func launchGame(bundleId: String) -> Bool {
        guard let workspaceClass = NSClassFromString("LSApplicationWorkspace") as AnyObject? else {
            return false
        }
        let selDefault = NSSelectorFromString("defaultWorkspace")
        guard workspaceClass.responds(to: selDefault),
              let workspace = workspaceClass.perform(selDefault)?.takeUnretainedValue() else {
            return false
        }

        let selOpen = NSSelectorFromString("openApplicationWithBundleID:")
        if workspace.responds(to: selOpen) {
            _ = workspace.perform(selOpen, with: bundleId)
            return true
        }
        return false
    }
}
