import SwiftUI

/// 设置页：发音设置、学习数据、关于
struct SettingsView: View {

    @EnvironmentObject private var store: AppStore

    @AppStorage("speechRate") private var speechRate: Double = 0.45
    @AppStorage("autoSpeak") private var autoSpeak: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("发音") {
                    Toggle("翻页自动发音", isOn: $autoSpeak)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("语速：\(speechRate <= 0.35 ? "慢" : speechRate <= 0.5 ? "正常" : "快")")
                        Slider(value: $speechRate, in: 0.1...0.7, step: 0.05)
                    }
                }

                Section("学习记录") {
                    HStack {
                        Text("上次学习")
                        Spacer()
                        Text(store.lastLessonId.map { "第 \($0) 课" } ?? "无")
                            .foregroundStyle(.secondary)
                    }
                    Button("清除上次学习记录", role: .destructive) {
                        store.clearLastLesson()
                    }
                    HStack {
                        Text("收藏的字")
                        Spacer()
                        Text("\(store.favorites.count) 个")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("已保存卡片")
                        Spacer()
                        Text("\(store.savedCards.count) 张")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("关于") {
                    LabeledRow(label: "应用", value: "汉字卡")
                    LabeledRow(label: "版本", value: "1.0.0")
                    LabeledRow(label: "字库", value: "零基础 200 字 · 40 课")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.green, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct LabeledRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}
