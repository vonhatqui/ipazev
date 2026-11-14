import Foundation

/// Dịch vụ tải và nạp trực tiếp file cache vào thư mục Documents của game
public final class FileReplacer {

    public static let shared = FileReplacer()
    private let fileManager = FileManager.default

    private init() {}

    /// Nạp file nhị phân vào đường dẫn mục tiêu trong Game Container
    /// - Parameters:
    ///   - data: Dữ liệu nhị phân của file tải từ server
    ///   - bundleId: Bundle ID của game (com.dts.freefireth hoặc com.dts.freefiremax)
    ///   - relativePath: Đường dẫn tương đối (VD: Documents/localConfig.json)
    /// - Returns: Thành công hay thất bại
    public func injectFile(data: Data, bundleId: String, relativePath: String) throws -> String {
        guard let containerPath = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            throw NSError(domain: "ZevCheatiOS", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Không tìm thấy thư mục dữ liệu của game (\(bundleId)). Vui lòng mở game ít nhất 1 lần!"
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

        // Ghi đè file mới
        try data.write(to: URL(fileURLWithPath: fullDestPath), options: .atomic)
        return fullDestPath
    }

    /// Reset tài khoản khách (Guest) bằng cách xóa identifier & keychain guest data
    public func resetGuestAccount(bundleId: String) -> Bool {
        guard let container = ContainerResolver.shared.resolveContainerPath(bundleId: bundleId) else {
            return false
        }
        let doc = (container as NSString).appendingPathComponent("Documents")
        let guestPaths = [
            (doc as NSString).appendingPathComponent("g_data"),
            (doc as NSString).appendingPathComponent("guest_info"),
            (doc as NSString).appendingPathComponent("app_guest_id.dat")
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
