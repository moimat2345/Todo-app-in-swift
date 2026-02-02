import SwiftUI
import Combine

// Gestionnaire global pour les célébrations
class CelebrationManager: ObservableObject {
    static let shared = CelebrationManager()
    
    @Published var showCelebration = false

    private init() {}

    func triggerCelebration() {
        showCelebration = true
    }
    
    func hideCelebration() {
        showCelebration = false
    }
}
