import SwiftUI

/// Living details painted over the still café: rain on the window, firelight, lamp glow and steam.
/// Every position is a fraction of the artwork, so the effects stay pinned to it at any window size.
struct CafeAtmosphere: View {
    let size: CGSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { timeline in
            let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, canvas in
                drawRain(&context, canvas, t)
                drawLamps(&context, canvas, t)
                drawFire(&context, canvas, t)
                drawSteam(&context, canvas, t)
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawRain(_ context: inout GraphicsContext, _ canvas: CGSize, _ t: Double) {
        let window = CGRect(x: canvas.width * 0.300, y: canvas.height * 0.255,
                            width: canvas.width * 0.150, height: canvas.height * 0.330)
        var clipped = context
        clipped.clip(to: Path(window))
        for i in 0..<70 {
            let seed = Double(i) * 12.9898
            let speed = 0.55 + fract(seed * 1.7) * 0.6
            let x = window.minX + fract(seed) * window.width
            let y = window.minY + fract(t * speed + seed) * window.height
            var streak = Path()
            streak.move(to: CGPoint(x: x, y: y))
            streak.addLine(to: CGPoint(x: x - 1, y: y + 9 + fract(seed * 3) * 14))
            clipped.stroke(streak, with: .color(.white.opacity(0.10 + fract(seed * 5) * 0.16)), lineWidth: 0.8)
        }
    }

    private func drawLamps(_ context: inout GraphicsContext, _ canvas: CGSize, _ t: Double) {
        let lamps: [(x: Double, y: Double, radius: Double, color: Color)] = [
            (0.195, 0.365, 0.10, Color(red: 1, green: 0.82, blue: 0.48)),
            (0.246, 0.405, 0.06, Color(red: 1, green: 0.72, blue: 0.36)),
            (0.273, 0.445, 0.07, Color(red: 1, green: 0.82, blue: 0.48)),
            (0.705, 0.445, 0.08, Color(red: 1, green: 0.82, blue: 0.48)),
        ]
        var glow = context
        glow.blendMode = .screen
        for (i, lamp) in lamps.enumerated() {
            let breathe = 0.20 + 0.04 * sin(t * 0.9 + Double(i) * 1.8)
            radial(&glow, CGPoint(x: canvas.width * lamp.x, y: canvas.height * lamp.y),
                   canvas.width * lamp.radius, lamp.color.opacity(breathe))
        }
    }

    private func drawFire(_ context: inout GraphicsContext, _ canvas: CGSize, _ t: Double) {
        let flicker = 0.30 + 0.09 * sin(t * 7.3) + 0.06 * sin(t * 13.1 + 1.2) + 0.04 * sin(t * 23.7)
        var glow = context
        glow.blendMode = .screen
        radial(&glow, CGPoint(x: canvas.width * 0.655, y: canvas.height * 0.700),
               canvas.width * 0.17, Color(red: 1, green: 0.45, blue: 0.14).opacity(flicker))
    }

    private func drawSteam(_ context: inout GraphicsContext, _ canvas: CGSize, _ t: Double) {
        let origin = CGPoint(x: canvas.width * 0.170, y: canvas.height * 0.700)
        let height = canvas.height * 0.10
        for i in 0..<9 {
            let p = fract(t * 0.16 + Double(i) / 9)
            let sway = sin(p * 7 + Double(i)) * canvas.width * 0.006 * (0.4 + p)
            let point = CGPoint(x: origin.x + sway, y: origin.y - p * height)
            radial(&context, point, canvas.width * (0.006 + p * 0.012),
                   .white.opacity((1 - p) * min(p * 5, 1) * 0.24))
        }
    }

    private func radial(_ context: inout GraphicsContext, _ center: CGPoint, _ radius: Double, _ color: Color) {
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
            with: .radialGradient(Gradient(colors: [color, color.opacity(0)]),
                                  center: center, startRadius: 0, endRadius: radius))
    }

    private func fract(_ value: Double) -> Double { value - floor(value) }
}
