import UIKit

/// Theme màu sắc chủ đạo của ZevCheatiOS (Khớp 100% bảng màu Logo Tím Cyber / Dark Neon)
public enum Theme {
    // Nền tối OLED
    public static let bg = UIColor(red: 0.031, green: 0.016, blue: 0.063, alpha: 1.0) // #080410
    public static let bgElevated = UIColor(red: 0.055, green: 0.031, blue: 0.114, alpha: 1.0) // #0e081d
    public static let card = UIColor(red: 0.071, green: 0.039, blue: 0.141, alpha: 0.88) // #120a24
    public static let cardStroke = UIColor(red: 0.616, green: 0.306, blue: 0.867, alpha: 0.32) // rgba(157, 78, 221, 0.32)

    // Màu điểm nhấn Neon Violet
    public static let accent = UIColor(red: 0.616, green: 0.306, blue: 0.867, alpha: 1.0) // #9d4edd
    public static let accentGlow = UIColor(red: 0.533, green: 0.0, blue: 0.973, alpha: 1.0) // #8800f8
    public static let accentLight = UIColor(red: 0.780, green: 0.490, blue: 1.0, alpha: 1.0) // #c77dff
    public static let accentDim = UIColor(red: 0.533, green: 0.0, blue: 0.973, alpha: 0.18)

    // Màu chữ
    public static let text = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
    public static let textSub = UIColor(red: 0.75, green: 0.72, blue: 0.85, alpha: 1.0)
    public static let textDim = UIColor(red: 0.52, green: 0.48, blue: 0.62, alpha: 1.0)

    // Trạng thái
    public static let success = UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 1.0) // #10b981
    public static let danger = UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0) // #ef4444
    public static let warning = UIColor(red: 0.961, green: 0.620, blue: 0.043, alpha: 1.0) // #f59e0b
}
