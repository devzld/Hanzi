import SwiftUI

/// 根视图：底部三个 Tab（首页 / 制作卡片 / 设置）
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("首页", systemImage: "house") }

            // 「制作卡片」直接进 Tab 时也需要导航栏（绿色标题栏）
            NavigationStack {
                CardMakerView()
            }
            .tabItem { Label("制作卡片", systemImage: "pencil") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStore())
        .environmentObject(SpeechService())
}
