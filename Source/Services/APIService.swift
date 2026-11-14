import Foundation
import UIKit

/// Dịch vụ kết nối API Server ZevCheatiOS
public final class APIService: NSObject, URLSessionDelegate {

    public static let shared = APIService()

    // Domain server mặc định trỏ về máy chủ hosting của bạn
    public var baseURL: String {
        get {
            if let custom = UserDefaults.standard.string(forKey: "zev.custom_base_url"), !custom.isEmpty {
                var clean = custom.trimmingCharacters(in: .whitespacesAndNewlines)
                if clean.hasSuffix("/zev_panel") {
                    clean = clean.replacingOccurrences(of: "/zev_panel", with: "")
                }
                while clean.hasSuffix("/") {
                    clean = String(clean.dropLast())
                }
                return clean
            }
            return "https://crackbomaydihihi.sbs"
        }
        set {
            var clean = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if clean.hasSuffix("/zev_panel") {
                clean = clean.replacingOccurrences(of: "/zev_panel", with: "")
            }
            while clean.hasSuffix("/") {
                clean = String(clean.dropLast())
            }
            UserDefaults.standard.set(clean, forKey: "zev.custom_base_url")
        }
    }

    public var baseUrl: String {
        return baseURL
    }

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        config.timeoutIntervalForResource = 60.0
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    private override init() {
        super.init()
    }

    // Tự động tin cậy chứng chỉ máy chủ / SSL handshake an toàn
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
        guard let url = URL(string: "\(baseURL)/api.php?action=checkMaintenance") else {
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

    public func checkMaintenanceStatus(completion: @escaping (Bool, String?) -> Void) {
        checkMaintenance { isM, msg in
            completion(isM, msg.isEmpty ? nil : msg)
        }
    }

    /// Xác thực Key Bản Quyền với server
    public func validateKey(key: String, completion: @escaping (Bool, String?, [String: Any]?) -> Void) {
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let endpoints = [
            "\(baseURL)/api.php?action=validateKey",
            "\(baseURL)/zev_panel/api.php?action=validateKey"
        ]
        performValidateKey(endpoints: endpoints, key: cleanKey, completion: completion)
    }

    private func performValidateKey(endpoints: [String], key: String, completion: @escaping (Bool, String?, [String: Any]?) -> Void) {
        guard let urlStr = endpoints.first, let url = URL(string: urlStr) else {
            DispatchQueue.main.async {
                completion(false, "Không thể kết nối đến máy chủ!", nil)
            }
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(deviceHWID, forHTTPHeaderField: "X-Zev-HWID")

        let body: [String: Any] = [
            "key": key,
            "hwid": deviceHWID,
            "model": UIDevice.current.model
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        session.dataTask(with: req) { [weak self] data, response, err in
            guard let self = self else { return }

            if let http = response as? HTTPURLResponse, http.statusCode == 404, endpoints.count > 1 {
                let remaining = Array(endpoints.dropFirst())
                self.performValidateKey(endpoints: remaining, key: key, completion: completion)
                return
            }

            if let err = err {
                DispatchQueue.main.async {
                    completion(false, "Lỗi kết nối máy chủ: \(err.localizedDescription)", nil)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, "Máy chủ không phản hồi dữ liệu!", nil)
                }
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                if let raw = String(data: data, encoding: .utf8), raw.contains("404 Not Found"), endpoints.count > 1 {
                    let remaining = Array(endpoints.dropFirst())
                    self.performValidateKey(endpoints: remaining, key: key, completion: completion)
                    return
                }
                DispatchQueue.main.async {
                    completion(false, "Phản hồi máy chủ không hợp lệ!", nil)
                }
                return
            }

            let valid = (json["valid"] as? Bool) ?? (json["ok"] as? Bool) ?? false
            let msg = (json["message"] as? String) ?? (valid ? "Xác thực thành công!" : "Khóa không hợp lệ hoặc đã hết hạn.")
            DispatchQueue.main.async {
                completion(valid, msg, json)
            }
        }.resume()
    }

    /// Lấy danh sách các Slot nạp file
    public func fetchFeatures(key: String, completion: @escaping (Bool, [[String: Any]]) -> Void) {
        guard let url = URL(string: "\(baseURL)/api.php?action=fetchFeatures&key=\(key)&hwid=\(deviceHWID)") else {
            completion(false, [])
            return
        }

        session.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let list = json["features"] as? [[String: Any]] else {
                DispatchQueue.main.async {
                    completion(false, [])
                }
                return
            }
            DispatchQueue.main.async {
                completion(true, list)
            }
        }.resume()
    }

    /// Tải trực tiếp file nhị phân theo slot key
    public func downloadFile(slot: String, key: String, completion: @escaping (Bool, String?, Data?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api.php?action=downloadFile&slot=\(slot)&key=\(key)&hwid=\(deviceHWID)") else {
            completion(false, "URL tải file không hợp lệ", nil)
            return
        }

        session.dataTask(with: url) { data, resp, err in
            if let err = err {
                DispatchQueue.main.async {
                    completion(false, err.localizedDescription, nil)
                }
                return
            }
            guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode), let data = data else {
                DispatchQueue.main.async {
                    completion(false, "Máy chủ không tìm thấy file hoặc key hết hạn!", nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true, nil, data)
            }
        }.resume()
    }

    /// Báo cáo trạng thái nạp file
    public func reportInjection(key: String, slot: String, success: Bool, error: String = "") {
        guard let url = URL(string: "\(baseURL)/api.php?action=reportInjection") else { return }
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
