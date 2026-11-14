import Foundation
import Darwin

/// Module Tự Bảo Vệ & Chống Dò Quét Bộ Nhớ / Debugger (Anti-Reversing & Anti-Detection)
public final class SecurityGuard {

    public static let shared = SecurityGuard()

    private init() {}

    /// Kích hoạt toàn bộ lớp bảo vệ
    public func activateAllProtections() {
        denyDebuggerAttach()
        checkFridaPorts()
        checkFridaLibraries()
    }

    /// Chặn gắn debugger qua ptrace(PT_DENY_ATTACH)
    private func denyDebuggerAttach() {
        typealias PtraceFunc = @convention(c) (Int32, pid_t, UnsafeMutableRawPointer?, Int32) -> Int32
        guard let handle = dlopen(nil, RTLD_NOW),
              let fnPtrace = dlsym(handle, "ptrace") else { return }
        let ptrace = unsafeBitCast(fnPtrace, to: PtraceFunc.self)
        _ = ptrace(31 /* PT_DENY_ATTACH */, 0, nil, 0)
    }

    /// Quét phát hiện cổng ngầm của Frida server (27042...)
    private func checkFridaPorts() {
        let testPorts: [UInt16] = [27042, 27043]
        for p in testPorts {
            var addr = sockaddr_in()
            addr.sin_family = sa_family_t(AF_INET)
            addr.sin_port = in_port_t(p.bigEndian)
            inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr)

            let sock = socket(AF_INET, SOCK_STREAM, 0)
            if sock >= 0 {
                withUnsafePointer(to: &addr) {
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        if connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) == 0 {
                            close(sock)
                            // Phát hiện cổng Frida mở
                        }
                    }
                }
                close(sock)
            }
        }
    }

    /// Quét các dylib hooking trong không gian bộ nhớ
    private func checkFridaLibraries() {
        let suspicious = ["frida-gadget", "frida-agent", "cydiasubstrate", "substitute"]
        let count = _dyld_image_count()
        for i in 0..<count {
            if let nameC = _dyld_get_image_name(i) {
                let name = String(cString: nameC).lowercased()
                for s in suspicious {
                    if name.contains(s) {
                        // Phát hiện thư viện can thiệp
                        break
                    }
                }
            }
        }
    }
}
