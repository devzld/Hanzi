import Foundation
import Combine

/// 全局数据存储：上次学习课程、收藏、已保存的卡片
final class AppStore: ObservableObject {

    @Published var lastLessonId: Int? {
        didSet { defaults.set(lastLessonId ?? -1, forKey: "lastLessonId") }
    }

    @Published var favorites: Set<String> {
        didSet { defaults.set(Array(favorites), forKey: "favorites") }
    }

    @Published var savedCards: [String] {
        didSet { defaults.set(savedCards, forKey: "savedCards") }
    }

    private let defaults = UserDefaults.standard

    init() {
        let last = defaults.integer(forKey: "lastLessonId")
        lastLessonId = last > 0 ? last : nil
        favorites = Set(defaults.stringArray(forKey: "favorites") ?? [])
        savedCards = defaults.stringArray(forKey: "savedCards") ?? []
    }

    func toggleFavorite(_ char: String) {
        if favorites.contains(char) {
            favorites.remove(char)
        } else {
            favorites.insert(char)
        }
    }

    func saveCard(_ text: String) -> Bool {
        let cleaned = text.replacingOccurrences(of: " ", with: "")
        guard !cleaned.isEmpty else { return false }
        if !savedCards.contains(cleaned) {
            savedCards.insert(cleaned, at: 0)
        }
        return true
    }

    func clearLastLesson() {
        lastLessonId = nil
    }
}
