import Foundation

/// Lõi định vị Container Sandbox dữ liệu của Game Free Fire (Hỗ trợ iOS 17 -> iOS 18.7.1+)
public final class ContainerResolver {

    public static let shared = ContainerResolver()

    // Bundle IDs mục tiêu
    public let bundleNormal = "com.dts.freefireth"
    public let bundleMax = "com.dts.freefiremax"

    private init() {}

    /// Lấy đường dẫn thư mục Data Container của Game
    public func resolveContainerPath(bundleId: String) -> String? {
        // Cách 1: Sử dụng MCM C Bridge chuẩn (mcm_bridge.m) đã test 100% trên 3105
        var errorStr: NSString?
        if let path = MCMActivateContainerPath(2, bundleId, false, &errorStr), !path.isEmpty {
            return path
        }

        // Cách 2: Quét thư mục Sandbox thực tế trên iOS
        if let path = resolveViaDirectoryScan(bundleId: bundleId) {
            return path
        }

        return nil
    }

    /// Lấy đường dẫn thư mục Documents của Game
    public func resolveDocumentsPath(bundleId: String) -> String? {
        guard let container = resolveContainerPath(bundleId: bundleId) else { return nil }
        let docPath = (container as NSString).appendingPathComponent("Documents")
        if !FileManager.default.fileExists(atPath: docPath) {
            try? FileManager.default.createDirectory(atPath: docPath, withIntermediateDirectories: true, attributes: nil)
        }
        return docPath
    }

    /// Quét các thư mục Application Container
    private func resolveViaDirectoryScan(bundleId: String) -> String? {
        let roots = [
            "/var/mobile/Containers/Data/Application",
            "/private/var/mobile/Containers/Data/Application"
        ]

        let fm = FileManager.default
        for root in roots {
            guard let dirs = try? fm.contentsOfDirectory(atPath: root) else { continue }
            for dir in dirs {
                let fullPath = (root as NSString).appendingPathComponent(dir)
                let metaPath = (fullPath as NSString).appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
                if fm.fileExists(atPath: metaPath) {
                    if let dict = NSDictionary(contentsOfFile: metaPath) as? [String: Any],
                       let id = dict["MCMMetadataIdentifier"] as? String,
                       id == bundleId {
                        return fullPath
                    }
                }
            }
        }
        return nil
    }
}
