import SwiftUI

/// 田字格：绿色边框 + 中间十字虚线，汉字居中（楷体）
struct Tianzige: View {

    /// 要显示的汉字，nil 则只显示空田字格
    let char: String?
    /// 字号（会随格子自动缩小以适配）
    var fontSize: CGFloat = 120

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // 外框（实线）
                Rectangle()
                    .stroke(Theme.green, lineWidth: 2)

                // 竖虚线
                DashedLine(from: CGPoint(x: w / 2, y: 0), to: CGPoint(x: w / 2, y: h))
                    .stroke(Theme.lightGreen, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))

                // 横虚线
                DashedLine(from: CGPoint(x: 0, y: h / 2), to: CGPoint(x: w, y: h / 2))
                    .stroke(Theme.lightGreen, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))

                // 汉字
                if let char, !char.isEmpty {
                    Text(char)
                        .font(.kai(fontSize))
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .frame(width: w * 0.86, height: h * 0.86)
                        .foregroundStyle(.black)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct DashedLine: Shape {
    let from: CGPoint
    let to: CGPoint

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        return p
    }
}

#Preview {
    Tianzige(char: "人", fontSize: 120)
        .padding(40)
        .background(Theme.background)
}
