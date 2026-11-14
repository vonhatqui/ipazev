import Foundation

/// Lõi định vị Container Sandbox dữ liệu của Game Free Fire (Hỗ trợ iOS 17 -> iOS 18+)
public final class ContainerResolver {

    public static let shared = ContainerResolver()

    // Bundle IDs mục tiêu
    public let bundleNormal = "com.dts.freefireth"
    public let bundleMax = "com.dts.freefiremax"

    private typealias ContainerQueryCreateFunc = @convention(c) (UInt64, UInt32) -> UnsafeMutableRawPointer?
    private typealias ContainerQuerySetClassFunc = @convention(c) (UnsafeMutableRawPointer, UInt64) -> Void
    private typealias ContainerQuerySetIdentifiersFunc = @convention(c) (UnsafeMutableRawPointer, UnsafeRawPointer) -> Void
    private typealias ContainerQueryGetSingleResultFunc = @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?
    private typealias ContainerQueryFreeFunc = @convention(c) (UnsafeMutableRawPointer) -> Void
    private typealias ContainerObjectGetPathFunc = @convention(c) (UnsafeMutableRawPointer) -> UnsafePointer<CChar>?
    private typealias ContainerObjectSandboxExtensionActivateFunc = @convention(c) (UnsafeMutableRawPointer) -> Int32
    private typealias ContainerObjectFreeFunc = @convention(c) (UnsafeMutableRawPointer) -> Void

    private init() {}

    /// Lấy đường dẫn thư mục Data Container của Game
    public func resolveContainerPath(bundleId: String) -> String? {
        // Cách 1: Sử dụng MobileContainerManager (libsystem_containermanager.dylib)
        if let path = resolveViaMCM(bundleId: bundleId) {
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

    // --- Private MCM Resolver ---
    private func resolveViaMCM(bundleId: String) -> String? {
        guard let handle = dlopen("/usr/lib/system/libsystem_containermanager.dylib", RTLD_NOW) else {
            return nil
        }
        defer { dlclose(handle) }

        guard let fnQueryCreate = dlsym(handle, "container_query_create") else { return nil }
        let queryCreate = unsafeBitCast(fnQueryCreate, to: ContainerQueryCreateFunc.self)

        guard let fnSetClass = dlsym(handle, "container_query_set_class"),
              let fnSetIds = dlsym(handle, "container_query_set_identifiers"),
              let fnGetResult = dlsym(handle, "container_query_get_single_result"),
              let fnQueryFree = dlsym(handle, "container_query_free"),
              let fnGetPath = dlsym(handle, "container_object_get_path"),
              let fnObjectFree = dlsym(handle, "container_object_free") else {
            return nil
        }

        let setClass = unsafeBitCast(fnSetClass, to: ContainerQuerySetClassFunc.self)
        let setIds = unsafeBitCast(fnSetIds, to: ContainerQuerySetIdentifiersFunc.self)
        let getResult = unsafeBitCast(fnGetResult, to: ContainerQueryGetSingleResultFunc.self)
        let queryFree = unsafeBitCast(fnQueryFree, to: ContainerQueryFreeFunc.self)
        let getPath = unsafeBitCast(fnGetPath, to: ContainerObjectGetPathFunc.self)
        let objectFree = unsafeBitCast(fnObjectFree, to: ContainerObjectFreeFunc.self)

        // Class 2: Data Container của Application
        guard let query = queryCreate(0, 0) else { return nil }
        defer { queryFree(query) }

        setClass(query, 2)

        let cfId = bundleId as CFString
        let idsArray = [cfId] as CFArray
        let unmanaged = Unmanaged.passUnretained(idsArray)
        setIds(query, unmanaged.toOpaque())

        guard let containerObj = getResult(query) else { return nil }
        defer { objectFree(containerObj) }

        // Kích hoạt sandbox extension nếu hàm có sẵn
        if let fnExtension = dlsym(handle, "container_object_sandbox_extension_activate") {
            let extensionActivate = unsafeBitCast(fnExtension, to: ContainerObjectSandboxExtensionActivateFunc.self)
            _ = extensionActivate(containerObj)
        }

        if let cPath = getPath(containerObj) {
            return String(cString: cPath)
        }

        return nil
    }

    // --- Private Directory Traversal ---
    private func resolveViaDirectoryScan(bundleId: String) -> String? {
        let basePath = "/private/var/mobile/Containers/Data/Application"
        guard let list = try? FileManager.default.contentsOfDirectory(atPath: basePath) else {
            return nil
        }

        for folder in list {
            let full = (basePath as NSString).appendingPathComponent(folder)
            let metaPath = (full as NSString).appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
            if FileManager.default.fileExists(atPath: metaPath),
               let dict = NSDictionary(contentsOfFile: metaPath),
               let id = dict["MCMMetadataIdentifier"] as? String,
               id == bundleId {
                return full
            }
        }
        return nil
    }
}

