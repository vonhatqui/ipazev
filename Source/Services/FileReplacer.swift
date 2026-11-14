import Foundation

/// Dịch vụ tải, phân tích vị trí và nạp/gỡ trực tiếp file cache vào Documents của Free Fire (Chuẩn kiến trúc Aurora Injector)
public final class FileReplacer {

    public static let shared = FileReplacer()
    private let fileManager = FileManager.default

    private init() {}

    /// Đường dẫn thư mục Bundle Assets trong Documents của Free Fire
    private let compulsorySubpath = "Documents/contentcache/Compulsory/ios/gameassetbundles"
    private let avatarSubpath = "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar"

    /// Logic thông minh phân tích file từ máy chủ để tự động định tuyến vị trí đặt trong Documents
    public func resolveTargetPath(fileName: String, slotKey: String = "", customPath: String? = nil) -> String {
        if let custom = customPath, !custom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return custom
        }

        let lowerName = fileName.lowercased()
        let lowerSlot = slotKey.lowercased()

        // 1. Aim / Headshot / Bullet / Hitbox Cache Engine
        if lowerName.contains("aim") || lowerName.contains("bullet") || lowerName.contains("headshot") || lowerName.contains("hitbox") || lowerSlot.contains("aim") {
            if lowerName.contains("cache") || lowerName.hasSuffix(".bin") {
                return "Documents/aim-cache.bin"
            }
            return "Documents/\(fileName)"
        }

        // 2. Assembly CSharp binary patch
        if lowerName.contains("assembly") || lowerName.contains("csharp") || lowerName.hasSuffix(".bytes") || lowerSlot.contains("assembly") {
            return "Documents/Assembly-CSharp-patch.bytes"
        }

        // 3. Asset Indexer
        if lowerName.contains("assetindexer") || lowerSlot.contains("asset") {
            return "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/assetindexer.U6Zffc4YIR3DslNj3cXvYGAqz58~3D"
        }

        // 4. Cache Resource
        if lowerName.contains("cache_res") || lowerSlot.contains("cache_res") {
            return "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/cache_res.GkLlYqzsX4AtTdE55sDMRh9sJOI~3D"
        }

        // 5. Avatar Bundles / Skin / Weapon 3D Mod
        if lowerName.contains("avatar") || lowerName.contains("skin") || lowerName.hasSuffix(".bundle") || lowerSlot.contains("skin") {
            return "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/\(fileName)"
        }

        // 6. Local Configuration / Proxy DNS setting
        if lowerName.contains("config") || lowerName.hasSuffix(".json") {
            return "Documents/localConfig.json"
        }

        // Mặc định nạp thẳng vào Documents
        return "Documents/\(fileName)"
    }

    /// Nạp file nhị phân vào đường dẫn mục tiêu trong Game Container
    @discardableResult
    public func injectFile(data: Data, bundleId: String, relativePath: String, fileName: String = "", slotKey: String = "") throws -> String {
        guard let containerPath = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            throw NSError(domain: "ZevCheatiOS", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Không tìm thấy Sandbox của game (\(bundleId)). Vui lòng mở game ít nhất 1 lần để tạo Documents!"
            ])
        }

        // Tự động phân tích đường dẫn tối ưu nếu relativePath rỗng
        let targetRel = relativePath.isEmpty ? resolveTargetPath(fileName: fileName, slotKey: slotKey) : relativePath
        let fullDestPath = (containerPath as NSString).appendingPathComponent(targetRel)
        let parentDir = (fullDestPath as NSString).deletingLastPathComponent

        // Tạo thư mục cha nếu chưa có
        if !fileManager.fileExists(atPath: parentDir) {
            try fileManager.createDirectory(atPath: parentDir, withIntermediateDirectories: true, attributes: nil)
        }

        let backupDir = (containerPath as NSString).appendingPathComponent("Documents/Zev_Backups")
        if !fileManager.fileExists(atPath: backupDir) {
            try? fileManager.createDirectory(atPath: backupDir, withIntermediateDirectories: true, attributes: nil)
        }

        // Ghi nhận file vào danh sách sổ cái ledger để Uninject chuẩn xác
        recordInjectedPath(targetRel, in: backupDir)

        // Tạo bản backup an toàn nếu file cũ đã tồn tại
        if fileManager.fileExists(atPath: fullDestPath) {
            let safeName = targetRel.replacingOccurrences(of: "/", with: "___")
            let backupPath = (backupDir as NSString).appendingPathComponent("\(safeName).bak")
            if !fileManager.fileExists(atPath: backupPath) {
                try? fileManager.copyItem(atPath: fullDestPath, toPath: backupPath)
            }
        }

        // Áp dụng cơ chế thay thế tệp an toàn (Safe Atomic Replacement) từ lõi 3105
        let targetURL = URL(fileURLWithPath: fullDestPath)
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try data.write(to: tempURL, options: .atomic)
        defer { try? fileManager.removeItem(at: tempURL) }

        if fileManager.fileExists(atPath: fullDestPath) {
            _ = try FileReplacementService.replace(target: targetURL, with: tempURL)
        } else {
            try fileManager.copyItem(at: tempURL, to: targetURL)
        }
        return fullDestPath
    }

    /// Ghi nhận đường dẫn tương đối đã inject vào ledger file
    private func recordInjectedPath(_ relPath: String, in backupDir: String) {
        let ledgerPath = (backupDir as NSString).appendingPathComponent("injected_ledger.json")
        var list: [String] = []
        if let data = try? Data(contentsOf: URL(fileURLWithPath: ledgerPath)),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [String] {
            list = arr
        }
        if !list.contains(relPath) {
            list.append(relPath)
            if let outData = try? JSONSerialization.data(withJSONObject: list, options: .prettyPrinted) {
                try? outData.write(to: URL(fileURLWithPath: ledgerPath), options: .atomic)
            }
        }
    }

    /// Khôi phục toàn bộ trạng thái gốc của game (UNINJECTOR - Xóa sạch mọi mod/file nạp vào)
    public func uninjectAll(bundleId: String) throws -> Int {
        guard let containerPath = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            throw NSError(domain: "ZevCheatiOS", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Không tìm thấy Sandbox của game (\(bundleId))."
            ])
        }

        var count = 0
        let backupDir = (containerPath as NSString).appendingPathComponent("Documents/Zev_Backups")
        let ledgerPath = (backupDir as NSString).appendingPathComponent("injected_ledger.json")

        // 1. Khôi phục từ danh sách ledger
        if let data = try? Data(contentsOf: URL(fileURLWithPath: ledgerPath)),
           let list = try? JSONSerialization.jsonObject(with: data) as? [String] {
            for rel in list {
                let fullDest = (containerPath as NSString).appendingPathComponent(rel)
                let safeName = rel.replacingOccurrences(of: "/", with: "___")
                let backupFile = (backupDir as NSString).appendingPathComponent("\(safeName).bak")

                if fileManager.fileExists(atPath: backupFile) {
                    // Trả lại file gốc
                    try? fileManager.removeItem(atPath: fullDest)
                    try? fileManager.copyItem(atPath: backupFile, toPath: fullDest)
                    try? fileManager.removeItem(atPath: backupFile)
                    count += 1
                } else {
                    // File này nạp mới hoàn toàn, xóa bỏ để trả về nguyên bản
                    if fileManager.fileExists(atPath: fullDest) {
                        try? fileManager.removeItem(atPath: fullDest)
                        count += 1
                    }
                }
            }
        }

        // 2. Quét dọn các file mod phổ biến nếu còn sót lại
        let commonCleanPaths = [
            "Documents/aim-cache.bin",
            "Documents/Assembly-CSharp-patch.bytes",
            "Documents/localConfig.json"
        ]
        for rel in commonCleanPaths {
            let fullPath = (containerPath as NSString).appendingPathComponent(rel)
            let safeName = rel.replacingOccurrences(of: "/", with: "___")
            let backupFile = (backupDir as NSString).appendingPathComponent("\(safeName).bak")
            if fileManager.fileExists(atPath: backupFile) {
                try? fileManager.removeItem(atPath: fullPath)
                try? fileManager.copyItem(atPath: backupFile, toPath: fullPath)
                try? fileManager.removeItem(atPath: backupFile)
                count += 1
            } else if fileManager.fileExists(atPath: fullPath) {
                try? fileManager.removeItem(atPath: fullPath)
                count += 1
            }
        }

        // Xóa sạch thư mục backup
        try? fileManager.removeItem(atPath: backupDir)
        return count
    }

    /// Tự động tìm và ghi đè toàn bộ các biến thể assetindexer
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

            if let files = try? fileManager.contentsOfDirectory(atPath: dir) {
                for f in files where f.hasPrefix("assetindexer.") {
                    let dest = (dir as NSString).appendingPathComponent(f)
                    try? data.write(to: URL(fileURLWithPath: dest), options: .atomic)
                    injectedPaths.append(dest)
                }
            }

            let specificDest = (dir as NSString).appendingPathComponent(specificName)
            try? data.write(to: URL(fileURLWithPath: specificDest), options: .atomic)
            if !injectedPaths.contains(specificDest) {
                injectedPaths.append(specificDest)
            }
        }

        return injectedPaths
    }

    /// Tự động tìm và ghi đè toàn bộ các biến thể cache_res
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

            if let files = try? fileManager.contentsOfDirectory(atPath: dir) {
                for f in files where f.hasPrefix("cache_res.") {
                    let dest = (dir as NSString).appendingPathComponent(f)
                    try? data.write(to: URL(fileURLWithPath: dest), options: .atomic)
                    injectedPaths.append(dest)
                }
            }

            let specificDest = (dir as NSString).appendingPathComponent(specificName)
            try? data.write(to: URL(fileURLWithPath: specificDest), options: .atomic)
            if !injectedPaths.contains(specificDest) {
                injectedPaths.append(specificDest)
            }
        }

        return injectedPaths
    }

    /// Reset tài khoản khách (Guest)
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

    /// Tự động khởi chạy Game Free Fire sau khi nạp cache xong
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
