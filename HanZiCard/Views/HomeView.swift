import SwiftUI

/// 首页：课程列表（零基础 1-200），分「一」（1-100）、「二」（101-200）两组
struct HomeView: View {

    @EnvironmentObject private var store: AppStore
    @State private var group = 0 // 0: 第1-20课(字1-100)  1: 第21-40课(字101-200)

    private var lessons: [Lesson] {
        HanziData.lessons.filter { group == 0 ? $0.id <= 20 : $0.id > 20 }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                groupTabs

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(lessons) { lesson in
                            NavigationLink(value: MakerRoute(
                                characters: lesson.characters,
                                title: "第\(lesson.rangeText)字"
                            )) {
                                LessonRow(lesson: lesson)
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(TapGesture().onEnded {
                                store.lastLessonId = lesson.id
                            })
                        }
                    }
                    .padding(16)
                }
            }
            .background(Theme.background)
            .navigationTitle("零基础 1-200")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.green, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "square.grid.2x2")
                        .foregroundStyle(.white)
                }
            }
            .navigationDestination(for: MakerRoute.self) { route in
                CardMakerView(initialCharacters: route.characters, courseTitle: route.title)
            }
        }
    }

    // 顶部「一 / 二」分组切换
    private var groupTabs: some View {
        HStack(spacing: 0) {
            groupTab(index: 0, symbol: "一", caption: "1-100")
            groupTab(index: 1, symbol: "二", caption: "101-200")
        }
        .background(Color.white)
        .overlay(alignment: .bottom) { Divider() }
    }

    private func groupTab(index: Int, symbol: String, caption: String) -> some View {
        let selected = group == index
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { group = index }
        } label: {
            VStack(spacing: 6) {
                Text(symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(selected ? Color.primary : Color.secondary)

                Text(caption)
                    .font(.system(size: 11))
                    .foregroundStyle(selected ? Theme.green : Color.secondary)

                // 下划线指示条
                Rectangle()
                    .fill(selected ? Theme.green : .clear)
                    .frame(height: 3)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStore())
        .environmentObject(SpeechService())
}
