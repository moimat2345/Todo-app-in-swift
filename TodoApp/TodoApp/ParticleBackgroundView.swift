import SwiftUI
import Combine

// Vue séparée pour les particules afin d'éviter les re-rendus
struct ParticleBackgroundView: View {
    let accentColor: Color
    let animationSpeed: Double
    let particleCount: Int
    let trigger: Int
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                AnimatedParticle(
                    accentColor: accentColor,
                    animationSpeed: animationSpeed,
                    index: i,
                    trigger: trigger
                )
            }
        }
        .allowsHitTesting(false) // Important : empêche les particules d'intercepter les clics
    }
}
