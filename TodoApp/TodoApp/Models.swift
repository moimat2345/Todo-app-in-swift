import SwiftUI
import Combine

// MARK: - Filter Type
enum FilterType: String, CaseIterable {
    case all = "Toutes"
    case active = "Actives"
    case completed = "Terminées"

    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .active: return "flame"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Accent Color
enum AccentColor: String, CaseIterable {
    case blue = "Bleu"
    case purple = "Violet"
    case pink = "Rose"
    case green = "Vert"
    case orange = "Orange"
    case red = "Rouge"
    case rainbow = "Arc-en-ciel"
    case gold = "Or"

    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        case .rainbow: return .purple
        case .gold: return .yellow
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .blue: return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .purple: return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pink: return LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .green: return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .orange: return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .red: return LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rainbow: return LinearGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gold: return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Font Size
enum FontSize: String, CaseIterable {
    case small = "Petit"
    case medium = "Moyen"
    case large = "Grand"
    case extraLarge = "Très Grand"

    var multiplier: CGFloat {
        switch self {
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.2
        case .extraLarge: return 1.4
        }
    }
}

// MARK: - App Settings (persisted via UserDefaults)
class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var isDarkMode: Bool {
        didSet { defaults.set(isDarkMode, forKey: "isDarkMode") }
    }
    @Published var particlesEnabled: Bool {
        didSet { defaults.set(particlesEnabled, forKey: "particlesEnabled") }
    }
    @Published var animationSpeed: Double {
        didSet { defaults.set(animationSpeed, forKey: "animationSpeed") }
    }
    @Published var particleCount: Int {
        didSet { defaults.set(particleCount, forKey: "particleCount") }
    }
    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: "soundEnabled") }
    }
    @Published var hapticEnabled: Bool {
        didSet { defaults.set(hapticEnabled, forKey: "hapticEnabled") }
    }
    @Published var celebrationEnabled: Bool {
        didSet { defaults.set(celebrationEnabled, forKey: "celebrationEnabled") }
    }
    @Published var accentColor: AccentColor {
        didSet { defaults.set(accentColor.rawValue, forKey: "accentColorRaw") }
    }
    @Published var fontSize: FontSize {
        didSet { defaults.set(fontSize.rawValue, forKey: "fontSizeRaw") }
    }

    init() {
        self.isDarkMode = defaults.bool(forKey: "isDarkMode")
        self.particlesEnabled = defaults.object(forKey: "particlesEnabled") as? Bool ?? true
        self.animationSpeed = defaults.object(forKey: "animationSpeed") as? Double ?? 1.0
        self.particleCount = defaults.object(forKey: "particleCount") as? Int ?? 20
        self.soundEnabled = defaults.object(forKey: "soundEnabled") as? Bool ?? true
        self.hapticEnabled = defaults.object(forKey: "hapticEnabled") as? Bool ?? true
        self.celebrationEnabled = defaults.object(forKey: "celebrationEnabled") as? Bool ?? true
        self.accentColor = AccentColor(rawValue: defaults.string(forKey: "accentColorRaw") ?? "") ?? .blue
        self.fontSize = FontSize(rawValue: defaults.string(forKey: "fontSizeRaw") ?? "") ?? .medium
    }

    func resetToDefaults() {
        isDarkMode = false
        accentColor = .blue
        particlesEnabled = true
        animationSpeed = 1.0
        particleCount = 20
        soundEnabled = true
        hapticEnabled = true
        fontSize = .medium
        celebrationEnabled = true
    }
}
