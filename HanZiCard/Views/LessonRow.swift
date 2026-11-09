import SwiftUI

/// 首页课程卡片：序号 + 上次学习角标 + 5 个田字格 + 打印/朗读/乱序
struct LessonRow: View {

    let lesson: Lesson

    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var speech: SpeechService

    // 支持「乱序」后本地重排
    @State private var chars: [String]
    @State private var showFeatureAlert = false

    init(lesson: Lesson) {
        self.lesson = lesson
        _chars = State(initialValue: lesson.characters)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题行
            HStack(spacing: 8) {
                Text("\(lesson.id)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)

                if store.lastLessonId == lesson.id {
                    Text("上次学习")
                        .font(.system(size: 10))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.85))
                        .clipShape(Capsule())
                }

                Spacer()

                Menu {
                    Button("乱序学习") { chars.shuffle() }
                    Button("恢复顺序") { chars = lesson.characters }
                    Button("朗读本课") { speech.speakAll(chars) }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.green)
                        .rotationEffect(.degrees(90))
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
            }

            // 田字格行
            HStack(spacing: 6) {
                ForEach(Array(chars.enumerated()), id: \.offset) { item in
                    Tianzige(char: item.element, fontSize: 52)
                        .frame(maxWidth: .infinity)
                }
            }

            // 底部操作行
            HStack(spacing: 18) {
                Spacer()

                Text("(共 \(chars.count) 个)")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.green)

                Button {
                    showFeatureAlert = true
                } label: {
                    Image(systemName: "printer")
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.green)
                }

                Button {
                    speech.speakAll(chars)
                } label: {
                    Image(systemName: "headphones")
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.green)
                }

                Button {
                    chars.shuffle()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.green)
                }
            }
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .onAppear { chars = lesson.characters }
        .alert("打印功能", isPresented: $showFeatureAlert) {
            Button("好", role: .cancel) {}
        } message: {
            Text("请先连接支持 AirPrint 的打印机。")
        }
    }
}

#Preview {
    LessonRow(lesson: Lesson(id: 1, characters: ["一", "二", "三", "人", "个"]))
        .environmentObject(AppStore())
        .environmentObject(SpeechService())
        .padding()
        .background(Theme.background)
}
