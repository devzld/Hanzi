import SwiftUI

@main
struct HanZiCardApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var speech = SpeechService()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .environmentObject(speech)
                .tint(Theme.green)
        }
    }
}
