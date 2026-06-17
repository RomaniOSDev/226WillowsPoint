import SwiftUI

struct RuneSymbolView: View {
    let symbol: RuneSymbol
    var size: CGFloat = 48
    var color: Color = Color("AppPrimary")

  var body: some View {
    Canvas { context, canvasSize in
      let rect = CGRect(origin: .zero, size: canvasSize)
      let path = runePath(for: symbol, in: rect)
      context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: max(2, size * 0.06), lineCap: .round, lineJoin: .round))
    }
    .frame(width: size, height: size)
  }

  private func runePath(for symbol: RuneSymbol, in rect: CGRect) -> Path {
    let cx = rect.midX
    let cy = rect.midY
    let r = min(rect.width, rect.height) * 0.38

    var path = Path()
    switch symbol {
    case .spiral:
      path.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: false)
      path.addArc(center: CGPoint(x: cx, y: cy), radius: r * 0.55, startAngle: .degrees(270), endAngle: .degrees(45), clockwise: true)
    case .cross:
      path.move(to: CGPoint(x: cx, y: cy - r))
      path.addLine(to: CGPoint(x: cx, y: cy + r))
      path.move(to: CGPoint(x: cx - r, y: cy))
      path.addLine(to: CGPoint(x: cx + r, y: cy))
    case .triangle:
      path.move(to: CGPoint(x: cx, y: cy - r))
      path.addLine(to: CGPoint(x: cx - r * 0.87, y: cy + r * 0.5))
      path.addLine(to: CGPoint(x: cx + r * 0.87, y: cy + r * 0.5))
      path.closeSubpath()
    case .diamond:
      path.move(to: CGPoint(x: cx, y: cy - r))
      path.addLine(to: CGPoint(x: cx + r, y: cy))
      path.addLine(to: CGPoint(x: cx, y: cy + r))
      path.addLine(to: CGPoint(x: cx - r, y: cy))
      path.closeSubpath()
    case .wave:
      path.move(to: CGPoint(x: cx - r, y: cy))
      path.addCurve(to: CGPoint(x: cx, y: cy), control1: CGPoint(x: cx - r * 0.5, y: cy - r), control2: CGPoint(x: cx - r * 0.2, y: cy + r))
      path.addCurve(to: CGPoint(x: cx + r, y: cy), control1: CGPoint(x: cx + r * 0.2, y: cy - r), control2: CGPoint(x: cx + r * 0.5, y: cy + r))
    case .sun:
      for i in 0..<8 {
        let angle = Double(i) * .pi / 4
        path.move(to: CGPoint(x: cx + cos(angle) * r * 0.4, y: cy + sin(angle) * r * 0.4))
        path.addLine(to: CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r))
      }
      path.addEllipse(in: CGRect(x: cx - r * 0.35, y: cy - r * 0.35, width: r * 0.7, height: r * 0.7))
    case .moon:
      path.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(-60), endAngle: .degrees(240), clockwise: false)
      path.addArc(center: CGPoint(x: cx + r * 0.35, y: cy), radius: r * 0.75, startAngle: .degrees(120), endAngle: .degrees(-120), clockwise: true)
    case .leaf:
      path.move(to: CGPoint(x: cx, y: cy + r))
      path.addQuadCurve(to: CGPoint(x: cx, y: cy - r), control: CGPoint(x: cx + r, y: cy))
      path.addQuadCurve(to: CGPoint(x: cx, y: cy + r), control: CGPoint(x: cx - r, y: cy))
    case .flame:
      path.move(to: CGPoint(x: cx, y: cy + r))
      path.addQuadCurve(to: CGPoint(x: cx, y: cy - r), control: CGPoint(x: cx + r, y: cy - r * 0.2))
      path.addQuadCurve(to: CGPoint(x: cx, y: cy + r), control: CGPoint(x: cx - r, y: cy - r * 0.2))
    case .star:
      for i in 0..<5 {
        let outerAngle = Double(i) * 2 * .pi / 5 - .pi / 2
        let innerAngle = outerAngle + .pi / 5
        let outer = CGPoint(x: cx + cos(outerAngle) * r, y: cy + sin(outerAngle) * r)
        let inner = CGPoint(x: cx + cos(innerAngle) * r * 0.4, y: cy + sin(innerAngle) * r * 0.4)
        if i == 0 { path.move(to: outer) } else { path.addLine(to: outer) }
        path.addLine(to: inner)
      }
      path.closeSubpath()
    case .circle:
      path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
    case .arrow:
      path.move(to: CGPoint(x: cx - r, y: cy))
      path.addLine(to: CGPoint(x: cx + r * 0.5, y: cy))
      path.move(to: CGPoint(x: cx + r * 0.2, y: cy - r * 0.5))
      path.addLine(to: CGPoint(x: cx + r * 0.7, y: cy))
      path.addLine(to: CGPoint(x: cx + r * 0.2, y: cy + r * 0.5))
    case .hexagon:
      for i in 0..<6 {
        let angle = Double(i) * .pi / 3 - .pi / 2
        let point = CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r)
        if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
      }
      path.closeSubpath()
    case .bolt:
      path.move(to: CGPoint(x: cx + r * 0.2, y: cy - r))
      path.addLine(to: CGPoint(x: cx - r * 0.3, y: cy + r * 0.1))
      path.addLine(to: CGPoint(x: cx + r * 0.05, y: cy + r * 0.1))
      path.addLine(to: CGPoint(x: cx - r * 0.2, y: cy + r))
      path.addLine(to: CGPoint(x: cx + r * 0.4, y: cy - r * 0.05))
      path.addLine(to: CGPoint(x: cx - r * 0.05, y: cy - r * 0.05))
      path.closeSubpath()
    case .eye:
      path.addEllipse(in: CGRect(x: cx - r, y: cy - r * 0.5, width: r * 2, height: r))
      path.addEllipse(in: CGRect(x: cx - r * 0.25, y: cy - r * 0.25, width: r * 0.5, height: r * 0.5))
    case .seal:
      path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
      for i in 0..<6 {
        let angle = Double(i) * .pi / 3
        path.move(to: CGPoint(x: cx + cos(angle) * r * 0.65, y: cy + sin(angle) * r * 0.65))
        path.addLine(to: CGPoint(x: cx + cos(angle) * r * 0.85, y: cy + sin(angle) * r * 0.85))
      }
    case .gate:
      path.move(to: CGPoint(x: cx - r, y: cy + r))
      path.addLine(to: CGPoint(x: cx - r, y: cy - r * 0.5))
      path.addQuadCurve(to: CGPoint(x: cx + r, y: cy - r * 0.5), control: CGPoint(x: cx, y: cy - r * 1.2))
      path.addLine(to: CGPoint(x: cx + r, y: cy + r))
    case .crown:
      path.move(to: CGPoint(x: cx - r, y: cy + r * 0.5))
      path.addLine(to: CGPoint(x: cx - r * 0.6, y: cy - r * 0.2))
      path.addLine(to: CGPoint(x: cx - r * 0.2, y: cy + r * 0.1))
      path.addLine(to: CGPoint(x: cx, y: cy - r))
      path.addLine(to: CGPoint(x: cx + r * 0.2, y: cy + r * 0.1))
      path.addLine(to: CGPoint(x: cx + r * 0.6, y: cy - r * 0.2))
      path.addLine(to: CGPoint(x: cx + r, y: cy + r * 0.5))
      path.closeSubpath()
    }
    return path
  }
}
