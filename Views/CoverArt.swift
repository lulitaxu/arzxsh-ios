import SwiftUI

struct CoverSpec {
    let style: CoverStyle
    let colors: [Color]
    let glow: Color
    let title: String
    let subtitle: String
    let layout: CoverTitleLayout
    let seed: String

    var initials: String {
        title.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined()
    }
}

extension Album {
    var coverSpec: CoverSpec {
        CoverSpec(style: coverStyle, colors: colors, glow: glow, title: title, subtitle: artist, layout: titleLayout, seed: id)
    }
}

extension Mix {
    var coverSpec: CoverSpec {
        CoverSpec(style: hero.coverStyle, colors: colors, glow: hero.glow, title: title, subtitle: subtitle, layout: hero.titleLayout, seed: id)
    }
}

struct CoverRandom: RandomNumberGenerator {
    var state: UInt64

    init(seed: String) {
        var hash: UInt64 = 1469598103934665603
        for byte in seed.utf8 {
            hash = (hash ^ UInt64(byte)) &* 1099511628211
        }
        state = hash == 0 ? 88172645463325252 : hash
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state >> 11
    }

    mutating func nextDouble() -> Double {
        Double(next() % 1_000_000) / 1_000_000.0
    }
}

struct CoverArt: View {
    let spec: CoverSpec
    var size: CGSize
    var animated: Bool = false
    var showsTitle: Bool = true

    private var W: Double { Double(size.width) }
    private var H: Double { Double(size.height) }
    private var detailScale: Double { min(W, H) > 400 ? 0.6 : 1.0 }

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    composition(phase: context.date.timeIntervalSinceReferenceDate)
                }
            } else {
                composition(phase: 0)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func composition(phase: Double) -> some View {
        let drift = phase > 0 ? 1.0 + 0.02 * (0.5 + 0.5 * sin(phase * 0.21)) : 1.0
        return ZStack {
            LinearGradient(colors: spec.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            motif(phase: phase)
            grainLayer
            titleLayer
        }
        .frame(width: size.width, height: size.height)
        .scaleEffect(drift)
        .clipped()
    }

    @ViewBuilder
    private func motif(phase: Double) -> some View {
        switch spec.style {
        case .skyline:
            skylineMotif(phase: phase)
        case .rain:
            rainMotif(phase: phase)
        case .sunDisc:
            sunMotif(phase: phase)
        case .paperFold:
            foldMotif(phase: phase)
        }
    }

    private var grainLayer: some View {
        Canvas { context, _ in
            let shortest = min(W, H)
            guard shortest >= 60 else { return }
            var rng = CoverRandom(seed: spec.seed + "-grain")
            let count = Int(min(240, W * H / 900) * detailScale)
            for _ in 0..<count {
                let x = rng.nextDouble() * W
                let y = rng.nextDouble() * H
                let dark = rng.nextDouble() > 0.5
                let rect = CGRect(x: x, y: y, width: 1.3, height: 1.3)
                context.fill(Path(rect), with: .color(dark ? Color.black.opacity(0.06) : Color.white.opacity(0.05)))
            }
        }
    }

    private func skylineBuildings() -> [(x: Double, w: Double, h: Double)] {
        var rng = CoverRandom(seed: spec.seed + "-buildings")
        var result: [(x: Double, w: Double, h: Double)] = []
        var x = -0.01
        while x < 1.0 {
            let bw = 0.07 + rng.nextDouble() * 0.09
            let bh = 0.15 + rng.nextDouble() * 0.20
            result.append((x: x, w: min(bw, 1.01 - x), h: bh))
            x += bw + 0.012
        }
        return result
    }

    private func skylineMotif(phase: Double) -> some View {
        let buildings = skylineBuildings()
        let haloPulse = 0.20 + 0.16 * (0.5 + 0.5 * sin(phase * 0.7))
        let cloudX = 0.66 + 0.05 * sin(phase * 0.11)
        return ZStack {
            Circle()
                .fill(spec.glow.opacity(phase > 0 ? haloPulse : 0.26))
                .frame(width: W * 0.62, height: W * 0.62)
                .position(x: W * 0.68, y: H * 0.30)
                .blur(radius: W * 0.05)
            Circle()
                .fill(spec.glow)
                .frame(width: W * 0.30, height: W * 0.30)
                .position(x: W * 0.68, y: H * 0.30)
            Ellipse()
                .fill(Color(red: 0.04, green: 0.05, blue: 0.16).opacity(0.55))
                .frame(width: W * 0.55, height: H * 0.13)
                .position(x: cloudX * W, y: H * 0.26)
                .blur(radius: W * 0.03)
            Canvas { context, _ in
                var rng = CoverRandom(seed: spec.seed + "-stars")
                let count = Int(46 * detailScale)
                for _ in 0..<count {
                    let sx = rng.nextDouble()
                    let sy = rng.nextDouble() * 0.62
                    let base = 0.35 + rng.nextDouble() * 0.6
                    let speed = 0.5 + rng.nextDouble() * 1.1
                    let offset = rng.nextDouble() * 6.28
                    let twinkle = phase > 0 ? 0.45 + 0.55 * (0.5 + 0.5 * sin(phase * speed + offset)) : 1.0
                    let r = (0.8 + rng.nextDouble() * 1.5) * max(0.7, min(W, H) / 220)
                    let rect = CGRect(x: sx * W - r, y: sy * H - r, width: r * 2, height: r * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(base * twinkle)))
                }
            }
            Canvas { context, _ in
                for b in buildings {
                    let rect = CGRect(x: b.x * W, y: H - b.h * H, width: b.w * W, height: b.h * H)
                    context.fill(Path(rect), with: .color(Color(red: 0.02, green: 0.02, blue: 0.09)))
                }
                if min(W, H) >= 100 {
                    var rng = CoverRandom(seed: spec.seed + "-windows")
                    for b in buildings {
                        let cols = max(1, Int(b.w / 0.034))
                        let rows = max(1, Int(b.h / 0.05))
                        for c in 0..<cols {
                            for r in 0..<rows {
                                guard rng.nextDouble() > 0.48 else { continue }
                                let wx = (b.x + 0.012 + Double(c) * 0.034) * W
                                let wy = H - b.h * H + (0.025 + Double(r) * 0.05) * H
                                let rect = CGRect(x: wx, y: wy, width: W * 0.013, height: H * 0.02)
                                context.fill(Path(rect), with: .color(Color(red: 1.0, green: 0.85, blue: 0.5).opacity(0.85)))
                            }
                        }
                    }
                }
            }
        }
    }

    private func rainMotif(phase: Double) -> some View {
        ZStack {
            Circle()
                .fill(spec.glow.opacity(0.5))
                .frame(width: W * 0.85, height: W * 0.85)
                .position(x: W * 0.16, y: H * 0.14)
                .blur(radius: W * 0.10)
            Circle()
                .fill(Color(red: 0.95, green: 0.35, blue: 0.75).opacity(0.42))
                .frame(width: W * 0.8, height: W * 0.8)
                .position(x: W * 0.88, y: H * 0.86)
                .blur(radius: W * 0.10)
            Canvas { context, _ in
                var rng = CoverRandom(seed: spec.seed + "-halftone")
                if min(W, H) >= 100 {
                    for row in 0..<6 {
                        for col in 0..<8 {
                            let cx = (0.05 + Double(col) * 0.052) * W
                            let cy = (0.95 - Double(row) * 0.048) * H
                            let r = (0.0035 + Double(col + row) * 0.0016) * min(W, H)
                            let rect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
                            context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(0.16)))
                        }
                    }
                }
                var rain = CoverRandom(seed: spec.seed + "-rain")
                let count = Int(30 * detailScale)
                for _ in 0..<count {
                    let rx = rain.nextDouble() * 1.15 - 0.05
                    let speed = 0.14 + rain.nextDouble() * 0.16
                    let offset = rain.nextDouble()
                    let len = 0.07 + rain.nextDouble() * 0.09
                    let travelled = phase > 0 ? (offset + phase * speed).truncatingRemainder(dividingBy: 1.3) : offset * 1.1
                    let topY = travelled - 0.15
                    var line = Path()
                    line.move(to: CGPoint(x: rx * W, y: topY * H))
                    line.addLine(to: CGPoint(x: (rx + len * 0.28) * W, y: (topY + len) * H))
                    context.stroke(line, with: .color(Color.white.opacity(0.34)), lineWidth: max(1, W * 0.005))
                }
            }
            VStack {
                Spacer()
                LinearGradient(colors: [Color.white.opacity(0), Color.white.opacity(0.13)], startPoint: .top, endPoint: .bottom)
                    .frame(height: H * 0.18)
            }
        }
    }

    private func sunMotif(phase: Double) -> some View {
        let sweepProgress = phase > 0 ? (phase / 16).truncatingRemainder(dividingBy: 1) : -1
        let sweepX = (-0.9 + sweepProgress * 2.2) * W
        let ringPulse = 1.0 + 0.025 * sin(phase * 0.5)
        return ZStack {
            Text(spec.initials)
                .font(.system(size: H * 0.92, weight: .black))
                .foregroundStyle(Color.white.opacity(0.10))
                .lineLimit(1)
                .fixedSize()
                .rotationEffect(.degrees(-8))
                .position(x: W * 0.78, y: H * 0.16)
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Color.white.opacity(0.26 - Double(i) * 0.08), lineWidth: max(1, W * 0.007))
                    .frame(width: W * (0.72 + Double(i) * 0.17), height: W * (0.72 + Double(i) * 0.17))
                    .position(x: W * 0.5, y: H * 0.56)
                    .scaleEffect(phase > 0 ? ringPulse : 1.0)
            }
            Circle()
                .fill(RadialGradient(colors: [spec.glow, spec.colors[2]], center: .center, startRadius: 2, endRadius: W * 0.30))
                .frame(width: W * 0.60, height: W * 0.60)
                .position(x: W * 0.5, y: H * 0.56)
            if min(W, H) >= 100 {
                Canvas { context, _ in
                    var lines = Path()
                    var y = H * 0.04
                    while y < H {
                        lines.move(to: CGPoint(x: 0, y: y))
                        lines.addLine(to: CGPoint(x: W, y: y))
                        y += H * 0.045
                    }
                    context.stroke(lines, with: .color(Color.black.opacity(0.05)), lineWidth: 1)
                }
            }
            Rectangle()
                .fill(LinearGradient(colors: [Color.white.opacity(0), Color.white.opacity(0.16), Color.white.opacity(0)], startPoint: .leading, endPoint: .trailing))
                .frame(width: W * 0.5, height: H * 1.6)
                .rotationEffect(.degrees(20))
                .position(x: sweepX, y: H * 0.5)
        }
    }

    private func foldMotif(phase: Double) -> some View {
        let bob = phase > 0 ? sin(phase * 0.9) * H * 0.006 : 0
        let rock = phase > 0 ? sin(phase * 0.6) * 1.6 : 0
        return ZStack {
            Canvas { context, _ in
                var facetA = Path()
                facetA.move(to: CGPoint(x: 0, y: 0))
                facetA.addLine(to: CGPoint(x: W, y: H * 0.34))
                facetA.addLine(to: CGPoint(x: W * 0.44, y: H * 0.56))
                facetA.addLine(to: CGPoint(x: 0, y: H * 0.8))
                facetA.closeSubpath()
                context.fill(facetA, with: .color(Color.white.opacity(0.14)))
                var facetB = Path()
                facetB.move(to: CGPoint(x: W, y: 0))
                facetB.addLine(to: CGPoint(x: W, y: H))
                facetB.addLine(to: CGPoint(x: W * 0.56, y: H * 0.64))
                facetB.addLine(to: CGPoint(x: W, y: H * 0.34))
                facetB.closeSubpath()
                context.fill(facetB, with: .color(Color.black.opacity(0.15)))
                var facetC = Path()
                facetC.move(to: CGPoint(x: 0, y: H * 0.8))
                facetC.addLine(to: CGPoint(x: W * 0.44, y: H * 0.56))
                facetC.addLine(to: CGPoint(x: W * 0.56, y: H))
                facetC.addLine(to: CGPoint(x: 0, y: H))
                facetC.closeSubpath()
                context.fill(facetC, with: .color(Color.white.opacity(0.08)))
                var route = Path()
                route.move(to: CGPoint(x: W * 0.02, y: H * 0.30))
                route.addQuadCurve(to: CGPoint(x: W * 0.36, y: H * 0.58), control: CGPoint(x: W * 0.16, y: H * 0.30))
                context.stroke(route, with: .color(Color.white.opacity(0.45)), style: StrokeStyle(lineWidth: max(1.2, W * 0.006), dash: [W * 0.008, W * 0.03]))
            }
            BoatShape()
                .fill(Color.white.opacity(0.94))
                .frame(width: W * 0.36, height: H * 0.18)
                .position(x: W * 0.47, y: H * 0.60 + bob)
                .rotationEffect(.degrees(rock))
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(Color.white.opacity(0.35 - Double(i) * 0.09))
                    .frame(width: W * (0.17 - Double(i) * 0.045), height: max(1.5, H * 0.008))
                    .position(x: W * 0.47, y: H * (0.715 + Double(i) * 0.038))
            }
        }
    }

    private struct BoatShape: Shape {
        func path(in rect: CGRect) -> Path {
            let w = Double(rect.width)
            let h = Double(rect.height)
            let ox = Double(rect.minX)
            let oy = Double(rect.minY)
            func point(_ x: Double, _ y: Double) -> CGPoint {
                CGPoint(x: ox + x * w, y: oy + y * h)
            }
            var path = Path()
            path.move(to: point(0.06, 0.58))
            path.addLine(to: point(0.94, 0.58))
            path.addLine(to: point(0.80, 0.88))
            path.addLine(to: point(0.20, 0.88))
            path.closeSubpath()
            path.move(to: point(0.50, 0.55))
            path.addLine(to: point(0.50, 0.06))
            path.addLine(to: point(0.80, 0.55))
            path.closeSubpath()
            path.move(to: point(0.46, 0.55))
            path.addLine(to: point(0.46, 0.16))
            path.addLine(to: point(0.24, 0.55))
            path.closeSubpath()
            return path
        }
    }

    @ViewBuilder
    private var titleLayer: some View {
        if showsTitle && min(W, H) >= 110 {
            switch spec.layout {
            case .bottomLeft:
                VStack(alignment: .leading, spacing: H * 0.012) {
                    titleText
                    subtitleText
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(H * 0.075)
            case .topLeft:
                VStack(alignment: .leading, spacing: H * 0.012) {
                    titleText
                    subtitleText
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(H * 0.075)
            case .centered:
                VStack(alignment: .center, spacing: H * 0.012) {
                    titleText
                    subtitleText
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, H * 0.085)
                .padding(.horizontal, H * 0.06)
            case .verticalRight:
                Text(spec.title)
                    .font(.system(size: H * 0.056, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .fixedSize()
                    .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                    .rotationEffect(.degrees(-90))
                    .frame(width: H, height: H)
                    .offset(x: W / 2 - H * 0.13)
            }
        }
    }

    private var titleText: some View {
        Text(spec.title)
            .font(.system(size: min(W, H) * 0.088, weight: .bold))
            .foregroundStyle(.white)
            .lineLimit(2)
            .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
    }

    private var subtitleText: some View {
        Text(spec.subtitle)
            .font(.system(size: min(W, H) * 0.056, weight: .medium))
            .foregroundStyle(Color.white.opacity(0.78))
            .lineLimit(1)
            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 1)
    }
}
