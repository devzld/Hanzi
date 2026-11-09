import SwiftUI

/// 制作卡片页：输入词语 → 生成大字卡，可左右翻页、收藏、朗读、保存
struct CardMakerView: View {

    /// 从课程列表进入时携带的初始字
    var initialCharacters: [String] = []
    /// 课程标题（如「第1-5字」），直接进 Tab 时为空
    var courseTitle: String = ""

    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var speech: SpeechService

    @State private var input: String = ""
    @State private var index: Int = 0
    @State private var showSavedSheet = false
    @State private var showInfoAlert = false
    @State private var showSavedToast = false
    @State private var featureMessage: FeatureMessage?
    @State private var didLoadInitial = false

    /// 当前所有字（过滤空白）
    private var chars: [String] {
        input.map { String($0) }.filter { !$0.isWhitespace && !$0.isNewline }
    }

    private var currentChar: String? {
        let list = chars
        guard !list.isEmpty else { return nil }
        return list[min(index, list.count - 1)]
    }

    var body: some View {
        VStack(spacing: 0) {
            inputBar
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)

            Spacer(minLength: 8)

            cardArea
                .padding(.horizontal, 24)

            Spacer(minLength: 4)

            HStack {
                Spacer()
                Text("\(chars.isEmpty ? 0 : min(index + 1, chars.count))/\(chars.count)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 28)
            }
            .padding(.bottom, 10)

            bottomToolbar
                .padding(.bottom, 6)
        }
        .background(Theme.background)
        .navigationTitle(courseTitle.isEmpty ? "汉字卡" : courseTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.green, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 18) {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear(perform: loadInitial)
        .onChange(of: input) { _ in index = 0 }
        .alert("小提示", isPresented: $showInfoAlert) {
            Button("好", role: .cancel) {}
        } message: {
            if let p = currentChar.flatMap({ HanziData.pinyin(of: $0) }) {
                Text("「\(currentChar ?? "")」读作 \(p)。点按卡片左右两侧或滑动可翻页。")
            } else {
                Text("点按卡片左右两侧或滑动可翻页，点爱心收藏本字。")
            }
        }
        .alert("已保存", isPresented: $showSavedToast) {
            Button("好", role: .cancel) {}
        } message: {
            Text("卡片「\(input)」已保存，可在「+」中查看。")
        }
        .alert(item: $featureMessage) { msg in
            Alert(title: Text(msg.text), dismissButton: .default(Text("好")))
        }
        .sheet(isPresented: $showSavedSheet) {
            SavedCardsSheet(loadCard: { text in
                input = text
                index = 0
            })
        }
    }

    // MARK: - 顶部输入栏

    private var inputBar: some View {
        HStack(spacing: 10) {
            Text("输入")
                .font(.system(size: 15))
                .foregroundStyle(.primary)

            Button {
                // 交换：载入最近保存的卡片
                if let last = store.savedCards.first {
                    input = last
                    index = 0
                }
            } label: {
                Image(systemName: "arrow.2.squarepath")
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
            }

            TextField("请输入词语", text: $input)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Theme.background)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Button("保存") {
                if store.saveCard(input) { showSavedToast = true }
            }
            .font(.system(size: 15))
            .foregroundStyle(Theme.green)

            Button {
                showSavedSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.green)
            }
        }
    }

    // MARK: - 大字卡

    private var cardArea: some View {
        VStack(spacing: 0) {
            // 可点击左右翻页的田字格
            ZStack {
                Tianzige(char: currentChar, fontSize: 150)
                    .padding(18)

                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { go(-1) }
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { go(1) }
                }

                if chars.isEmpty {
                    Text("输入词语开始制作卡片")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .offset(y: 90)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { v in
                        if v.translation.width < -40 { go(1) }
                        if v.translation.width > 40 { go(-1) }
                    }
            )

            // 卡片内底部：信息 / 收藏 / 朗读
            HStack(spacing: 26) {
                Button {
                    showInfoAlert = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 19))
                        .foregroundStyle(Theme.green)
                }

                Button {
                    if let c = currentChar { store.toggleFavorite(c) }
                } label: {
                    let isFav = currentChar.map { store.favorites.contains($0) } ?? false
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 19))
                        .foregroundStyle(Theme.green)
                }

                Button {
                    if let c = currentChar { speech.speak(c) }
                } label: {
                    Image(systemName: "play.rectangle")
                        .font(.system(size: 19))
                        .foregroundStyle(Theme.green)
                }

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 14)
        }
    }

    // MARK: - 底部工具栏

    private var bottomToolbar: some View {
        HStack(spacing: 34) {
            toolIcon("square.and.arrow.down", name: "保存图片")
            ShareLink(item: currentChar ?? "") {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundStyle(.gray)
            }
            toolIcon("printer", name: "打印")
            toolIcon("headphones", name: "跟读")
            toolIcon("airplay.video", name: "投屏")
            toolIcon("square.stack.3d.up", name: "卡片集")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.6))
    }

    private func toolIcon(_ systemName: String, name: String) -> some View {
        Button {
            featureMessage = FeatureMessage(text: "「\(name)」功能开发中，敬请期待。")
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 20))
                .foregroundStyle(.gray)
        }
    }

    // MARK: - 逻辑

    private func go(_ step: Int) {
        let count = chars.count
        guard count > 0 else { return }
        index = (index + step + count) % count
        if UserDefaults.standard.bool(forKey: "autoSpeak"), let c = currentChar {
            speech.speak(c)
        }
    }

    private func loadInitial() {
        guard !didLoadInitial else { return }
        didLoadInitial = true
        if !initialCharacters.isEmpty {
            input = initialCharacters.joined()
        }
        if UserDefaults.standard.bool(forKey: "autoSpeak"), let c = currentChar {
            speech.speak(c)
        }
    }
}

/// 已保存卡片列表
struct SavedCardsSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    var loadCard: (String) -> Void

    var body: some View {
        NavigationStack {
            List {
                if store.savedCards.isEmpty {
                    Text("暂无保存的卡片")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.savedCards, id: \.self) { card in
                        Button {
                            loadCard(card)
                            dismiss()
                        } label: {
                            HStack {
                                Text(card)
                                    .font(.kai(20))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { store.savedCards.remove(atOffsets: $0) }
                }
            }
            .navigationTitle("我的卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

/// 功能提示（用于 alert(item:)）
struct FeatureMessage: Identifiable {
    let id = UUID()
    let text: String
}

#Preview {
    NavigationStack {
        CardMakerView(initialCharacters: ["一", "二", "三", "人", "个"])
    }
    .environmentObject(AppStore())
    .environmentObject(SpeechService())
}
