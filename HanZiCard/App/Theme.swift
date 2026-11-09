import SwiftUI

enum Theme {
    /// 主绿色（接近截图中的微信绿）
    static let green = Color(red: 0.106, green: 0.647, blue: 0.369)
    /// 田字格虚线用浅绿
    static let lightGreen = Color(red: 0.106, green: 0.647, blue: 0.369).opacity(0.55)
    /// 页面浅灰背景
    static let background = Color(red: 0.949, green: 0.957, blue: 0.957)
    /// 卡片白底
    static let card = Color.white
}

/// 楷体字体（田字格中的汉字），系统缺失时自动回退到默认字体
extension Font {
    static func kai(_ size: CGFloat) -> Font {
        .custom("Kaiti SC", size: size)
    }
}
