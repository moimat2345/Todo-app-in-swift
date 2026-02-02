import SwiftUI
import Combine

// MARK: - Animated Particle
struct AnimatedParticle: View {
    let accentColor: Color
    let animationSpeed: Double
    let index: Int
    let trigger: Int

    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var scale: CGFloat = 1
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.1

    private let size: CGFloat
    private let baseX: CGFloat
    private let baseY: CGFloat

    init(accentColor: Color, animationSpeed: Double, index: Int, trigger: Int = 0) {
        self.accentColor = accentColor
        self.animationSpeed = animationSpeed
        self.index = index
        self.trigger = trigger
        self.size = CGFloat.random(in: 15...50)
        self.baseX = CGFloat.random(in: -400...400)
        self.baseY = CGFloat.random(in: -300...300)
    }

    var body: some View {
        Circle()
            .fill(accentColor.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(x: baseX + xOffset, y: baseY + yOffset)
            .onAppear {
                startContinuousAnimation()
            }
            .onChange(of: trigger) { _, _ in
                triggerReaction()
            }
    }

    private func startContinuousAnimation() {
        withAnimation(
            .easeInOut(duration: Double.random(in: 3...8) / animationSpeed)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.2)
        ) {
            xOffset = CGFloat.random(in: -100...100)
            yOffset = CGFloat.random(in: -150...150)
        }

        withAnimation(
            .easeInOut(duration: Double.random(in: 2...5) / animationSpeed)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.1)
        ) {
            scale = CGFloat.random(in: 0.5...1.5)
        }

        withAnimation(
            .linear(duration: Double.random(in: 8...15) / animationSpeed)
            .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }

        withAnimation(
            .easeInOut(duration: Double.random(in: 3...6) / animationSpeed)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.3)
        ) {
            opacity = Double.random(in: 0.05...0.2)
        }
    }

    private func triggerReaction() {
        withAnimation(.easeOut(duration: 0.8)) {
            xOffset = CGFloat.random(in: -200...200)
            yOffset = CGFloat.random(in: -200...200)
            scale = CGFloat.random(in: 0.8...2.0)
        }

        withAnimation(.easeOut(duration: 0.6)) {
            rotation += Double.random(in: 180...720)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            restartNormalAnimation()
        }
    }

    private func restartNormalAnimation() {
        withAnimation(
            .easeInOut(duration: Double.random(in: 3...8) / animationSpeed)
            .repeatForever(autoreverses: true)
        ) {
            xOffset = CGFloat.random(in: -100...100)
            yOffset = CGFloat.random(in: -150...150)
        }

        withAnimation(
            .easeInOut(duration: Double.random(in: 2...5) / animationSpeed)
            .repeatForever(autoreverses: true)
        ) {
            scale = CGFloat.random(in: 0.5...1.5)
        }

        withAnimation(
            .easeInOut(duration: Double.random(in: 3...6) / animationSpeed)
            .repeatForever(autoreverses: true)
        ) {
            opacity = Double.random(in: 0.05...0.2)
        }
    }
}

// MARK: - Success Celebration
struct SuccessCelebration: View {
    @State private var particles: [CelebrationParticle] = []
    @State private var showText = false
    @State private var textScale: CGFloat = 0.1
    @State private var textOpacity: Double = 0

    let text: String
    let onComplete: () -> Void

    init(text: String = "Tâche terminée !", onComplete: @escaping () -> Void) {
        self.text = text
        self.onComplete = onComplete
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles.indices, id: \.self) { index in
                    Circle()
                        .fill(particles[index].color)
                        .frame(width: particles[index].size, height: particles[index].size)
                        .offset(x: particles[index].x, y: particles[index].y)
                        .opacity(particles[index].opacity)
                        .scaleEffect(particles[index].scale)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                if showText {
                    VStack(spacing: 10) {
                        Text("🎉")
                            .font(.system(size: 80))

                        Text("Bravo !")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))

                        Text(text)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .scaleEffect(textScale)
                    .opacity(textOpacity)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            startCelebration()
        }
    }

    private func startCelebration() {
        particles = (0..<50).map { _ in
            CelebrationParticle(
                x: CGFloat.random(in: -300...300),
                y: CGFloat.random(in: -300...300),
                size: CGFloat.random(in: 10...30),
                color: [.red, .orange, .yellow, .green, .blue, .purple, .pink].randomElement() ?? .blue,
                opacity: 1.0,
                scale: 1.0
            )
        }

        withAnimation(.easeOut(duration: 2.5)) {
            for i in particles.indices {
                particles[i].x += CGFloat.random(in: -500...500)
                particles[i].y += CGFloat.random(in: -500...500)
                particles[i].opacity = 0
                particles[i].scale = 0.1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showText = true
            withAnimation(.bouncy(duration: 0.6)) {
                textScale = 1.0
                textOpacity = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                textOpacity = 0
                textScale = 0.1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onComplete()
        }
    }
}

struct CelebrationParticle {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
    var scale: CGFloat
}
