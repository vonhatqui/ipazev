import Foundation

/// Dịch vụ kết nối API Server ZevCheatiOS
public final class APIService: NSObject, URLSessionDelegate {

    public static let shared = APIService()

    // Domain server mặc định
    public var baseUrl: String {
        get {
            if let custom = UserDefaults.standard.string(forKey: "zev.custom_base_url"), !custom.isEmpty {
                return custom
            }
            return "https://crackbomaydihihi.sbs/zev_panel"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zev.custom_base_url")
        }
    }

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    private override init() {
        super.init()
    }

    // Tự động tin cậy chứng chỉ máy chủ Root CA / MITM proxy
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }

    /// Lấy mã định danh phần cứng (HWID) duy nhất của thiết bị
    public var deviceHWID: String {
        let key = "zev.device_hwid_v2"
        if let stored = UserDefaults.standard.string(forKey: key), !stored.isEmpty {
            return stored
        }
        let raw = "\(UIDevice.current.name)_\(UIDevice.current.systemVersion)_\(UUID().uuidString)"
        let hwid = "ZEV" + String(raw.hashValue, radix: 16, uppercase: true) + String(UUID().uuidString.prefix(8))
        UserDefaults.standard.set(hwid, forKey: key)
        return hwid
    }

    /// Kiểm tra trạng thái bảo trì hệ thống
    public func checkMaintenance(completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "\(baseUrl)/api.php?action=checkMaintenance") else {
            completion(false, "")
            return
        }

        session.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(false, "")
                return
            }
            let isM = (json["maintenance"] as? Bool) ?? false
            let msg = (json["message"] as? String) ?? "Hệ thống đang bảo trì!"
            completion(isM, msg)
        }.resume()
    }

    /// Xác thực Key Bản Quyền
    public func validateKey(_ key: String, completion: @escaping (Bool, String, [String: Any]?) -> Void) {
        guard let url = URL(string: "\(baseUrl)/api.php?action=validateKey") else {
            completion(false, "URL máy chủ không hợp lệ!", nil)
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(deviceHWID, forHTTPHeaderField: "X-Zev-HWID")

        let body: [String: Any] = [
            "key": key.trimmingCharacters(in: .whitespacesAndNewlines),
            "hwid": deviceHWID,
            "model": UIDevice.current.model
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        session.dataTask(with: req) { data, _, err in
            if let err = err {
                completion(false, "Lỗi kết nối máy chủ: \(err.localizedDescription)", nil)
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(false, "Phản hồi máy chủ không hợp lệ!", nil)
                return
            }

            let valid = (json["valid"] as? Bool) ?? false
            let msg = (json["message"] as? String) ?? (valid ? "Xác thực thành công!" : "Key không hợp lệ!")
            completion(valid, msg, json)
        }.resume()
    }

    /// Lấy danh sách các Slot nạp file
    public func fetchFeatures(key: String, completion: @escaping (Bool, [[String: Any]]) -> Void) {
        guard let url = URL(string: "\(baseUrl)/api.php?action=fetchFeatures&key=\(key)&hwid=\(deviceHWID)") else {
            completion(false, [])
            return
        }

        session.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let list = json["features"] as? [[String: Any]] else {
                completion(false, [])
                return
            }
            completion(true, list)
        }.resume()
    }

    /// Tải dữ liệu nhị phân của slot file
    public func downloadSlotFile(urlStr: String, completion: @escaping (Data?, String?, Error?) -> Void) {
        guard let url = URL(string: urlStr) else {
            completion(nil, nil, NSError(domain: "ZevCheatiOS", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL tải file không hợp lệ!"]))
            return
        }

        session.dataTask(with: url) { data, resp, err in
            if let err = err {
                completion(nil, nil, err)
                return
            }
            let targetPath = (resp as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-Zev-Target-Path")
            completion(data, targetPath, nil)
        }.resume()
    }

    /// Báo cáo trạng thái nạp file
    public func reportInjection(key: String, slot: String, success: Bool, error: String = "") {
        guard let url = URL(string: "\(baseUrl)/api.php?action=reportInjection") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "key": key,
            "hwid": deviceHWID,
            "slot": slot,
            "success": success,
            "error": error
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        session.dataTask(with: req).resume()
    }
}
