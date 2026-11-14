import Foundation
import Network

/// Máy chủ cục bộ chạy ngầm phục vụ cấp phát profile cấu hình .mobileconfig cho Safari
public final class LocalConfigServer {

    public static let shared = LocalConfigServer()
    private var listener: NWListener?
    public private(set) var port: UInt16 = 8089

    private init() {}

    public func start(completion: ((Bool) -> Void)? = nil) {
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port) ?? 8089)

            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }

            listener?.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    completion?(true)
                case .failed:
                    completion?(false)
                default:
                    break
                }
            }

            listener?.start(queue: .global(qos: .utility))
        } catch {
            completion?(false)
        }
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global(qos: .utility))
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4096) { [weak self] data, _, isComplete, _ in
            guard let self = self, let data = data,
                  let requestStr = String(data: data, encoding: .utf8) else {
                connection.cancel()
                return
            }

            if requestStr.contains("GET /mobileconfig") || requestStr.contains("GET /ZevCheatiOS.mobileconfig") {
                self.serveMobileConfig(connection: connection)
            } else {
                let html = "<html><body><h3>ZevCheatiOS Local Secure Bridge Active</h3></body></html>"
                let response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: \(html.utf8.count)\r\nConnection: close\r\n\r\n\(html)"
                connection.send(content: response.data(using: .utf8), completion: .contentProcessed({ _ in
                    connection.cancel()
                }))
            }
        }
    }

    private func serveMobileConfig(connection: NWConnection) {
        let dnsUrl = "https://dns.adguard-dns.com/dns-query"
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>PayloadContent</key>
            <array>
                <dict>
                    <key>DNSSettings</key>
                    <dict>
                        <key>DNSProtocol</key>
                        <string>HTTPS</string>
                        <key>ServerURL</key>
                        <string>\(dnsUrl)</string>
                        <key>ServerAddresses</key>
                        <array>
                            <string>94.140.14.14</string>
                            <string>94.140.15.15</string>
                        </array>
                    </dict>
                    <key>PayloadDescription</key>
                    <string>Kich hoat Secure DNS Proxy cho ZevCheatiOS.</string>
                    <key>PayloadDisplayName</key>
                    <string>ZevCheatiOS Secure DNS</string>
                    <key>PayloadIdentifier</key>
                    <string>com.zev.proxy.dns</string>
                    <key>PayloadType</key>
                    <string>com.apple.dnsSettings.managed</string>
                    <key>PayloadUUID</key>
                    <string>7F3E2A10-6C21-4B8D-9E4A-1A2B3C4D5E6F</string>
                    <key>PayloadVersion</key>
                    <integer>1</integer>
                </dict>
            </array>
            <key>PayloadDescription</key>
            <string>Cai dat de bao mat ket noi ZevCheatiOS.</string>
            <key>PayloadDisplayName</key>
            <string>ZevCheatiOS Profile</string>
            <key>PayloadIdentifier</key>
            <string>com.zevcheatios.profile</string>
            <key>PayloadOrganization</key>
            <string>ZevCheatiOS</string>
            <key>PayloadRemovalDisallowed</key>
            <false/>
            <key>PayloadType</key>
            <string>Configuration</string>
            <key>PayloadUUID</key>
            <string>2B9D4C16-8A70-4F31-B2C5-0E9F7A6D1C83</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
        </plist>
        """

        let payloadData = xml.data(using: .utf8) ?? Data()
        let headers = "HTTP/1.1 200 OK\r\nContent-Type: application/x-apple-aspen-config\r\nContent-Disposition: attachment; filename=\"ZevCheatiOS.mobileconfig\"\r\nContent-Length: \(payloadData.count)\r\nConnection: close\r\n\r\n"
        var fullData = headers.data(using: .utf8) ?? Data()
        fullData.append(payloadData)

        connection.send(content: fullData, completion: .contentProcessed({ _ in
            connection.cancel()
        }))
    }
}

