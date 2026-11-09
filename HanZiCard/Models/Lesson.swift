import Foundation

/// 一课汉字（默认每课 5 个字）
struct Lesson: Identifiable, Hashable {
    let id: Int
    var characters: [String]

    var rangeText: String {
        let start = (id - 1) * 5 + 1
        let end = id * 5
        return "\(start)-\(end)"
    }
}

/// 跳转到卡片制作页的路由
struct MakerRoute: Hashable {
    var characters: [String]
    var title: String
}
