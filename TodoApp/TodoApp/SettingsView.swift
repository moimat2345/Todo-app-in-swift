import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var showAdvancedSettings = false
    
    var body: some View {
        mainContent
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            headerSection
            scrollContent
            closeButton
        }
        .padding()
        .frame(width: 500, height: 600)
        .background(.ultraThinMaterial)
    }
    
    private var headerSection: some View {
        Text("Paramètres")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                appearanceCard
                behaviorCard
                
                if showAdvancedSettings {
                    advancedCard
                }
                
                toggleAdvancedButton
            }
            .padding()
        }
    }
    
    private var closeButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "xmark")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text("Fermer")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Apparence")
                .font(.headline)
            
            darkModeToggle
            colorGrid
            fontSizePicker
            // SUPPRIMÉ: iconPicker
        }
        .padding()
        .background(cardBackground)
    }
    
    private var darkModeToggle: some View {
        HStack {
            Image(systemName: "moon.fill")
                .foregroundColor(settings.accentColor.color)
                .frame(width: 20)
            
            Toggle("Mode sombre", isOn: Binding(
                get: { settings.isDarkMode },
                set: { settings.isDarkMode = $0 }
            ))
            .toggleStyle(.switch)
        }
    }
    
    private var colorGrid: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(settings.accentColor.color)
                    .frame(width: 20)
                
                Text("Couleur d'accent")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(AccentColor.allCases, id: \.self) { color in
                    colorButton(for: color)
                }
            }
        }
    }
    
    private func colorButton(for color: AccentColor) -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                settings.accentColor = color
            }
        }) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.gradient)
                .frame(height: 40)
                .overlay(strokeOverlay(for: color))
                .overlay(colorLabel(for: color))
                .scaleEffect(settings.accentColor == color ? 1.1 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func strokeOverlay(for color: AccentColor) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.white, lineWidth: settings.accentColor == color ? 3 : 0)
    }
    
    private func colorLabel(for color: AccentColor) -> some View {
        Text(color.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
    }
    
    private var fontSizePicker: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "textformat.size")
                    .foregroundColor(settings.accentColor.color)
                    .frame(width: 20)
                
                Text("Taille du texte")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Picker("Taille", selection: Binding(
                get: { settings.fontSize },
                set: { settings.fontSize = $0 }
            )) {
                ForEach(FontSize.allCases, id: \.self) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // SUPPRIMÉ: iconPicker et iconButton complètement
    
    private var behaviorCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🎵 Comportement")
                .font(.headline)
            
            soundToggle
            hapticToggle
            particlesToggle
            celebrationToggle
            // SUPPRIMÉ: subtasksToggle
        }
        .padding()
        .background(cardBackground)
    }
    
    private var soundToggle: some View {
        HStack {
            Image(systemName: "speaker.wave.2.fill")
                .foregroundColor(settings.accentColor.color)
                .frame(width: 20)
            
            Toggle("Sons activés", isOn: Binding(
                get: { settings.soundEnabled },
                set: { settings.soundEnabled = $0 }
            ))
            .toggleStyle(.switch)
        }
    }
    
    private var hapticToggle: some View {
        HStack {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .foregroundColor(settings.accentColor.color)
                .frame(width: 20)
            
            Toggle("Vibrations", isOn: Binding(
                get: { settings.hapticEnabled },
                set: { settings.hapticEnabled = $0 }
            ))
            .toggleStyle(.switch)
        }
    }
    
    private var particlesToggle: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(settings.accentColor.color)
                .frame(width: 20)
            
            Toggle("Particules", isOn: Binding(
                get: { settings.particlesEnabled },
                set: { settings.particlesEnabled = $0 }
            ))
            .toggleStyle(.switch)
        }
    }
    
    private var celebrationToggle: some View {
        HStack {
            Image(systemName: "party.popper.fill")
                .foregroundColor(settings.accentColor.color)
                .frame(width: 20)
            
            Toggle("Animations de célébration", isOn: Binding(
                get: { settings.celebrationEnabled },
                set: { settings.celebrationEnabled = $0 }
            ))
            .toggleStyle(.switch)
        }
    }
    
    // SUPPRIMÉ: subtasksToggle car maintenant contrôlé individuellement par tâche
    
    private var advancedCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🔧 Avancé")
                .font(.headline)
            
            animationSpeedSlider
            particleCountSlider
            resetButton
        }
        .padding()
        .background(cardBackground)
    }
    
    private var animationSpeedSlider: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "speedometer")
                    .foregroundColor(settings.accentColor.color)
                    .frame(width: 20)
                
                Text("Vitesse animations")
                Spacer()
                Text("\(settings.animationSpeed, specifier: "%.1f")x")
                    .foregroundColor(.secondary)
            }
            
            Slider(value: Binding(
                get: { settings.animationSpeed },
                set: { settings.animationSpeed = $0 }
            ), in: 0.5...3.0, step: 0.1)
            .accentColor(settings.accentColor.color)
        }
    }
    
    private var particleCountSlider: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .foregroundColor(settings.accentColor.color)
                    .frame(width: 20)
                
                Text("Nombre de particules")
                Spacer()
                Text("\(settings.particleCount)")
                    .foregroundColor(.secondary)
            }
            
            Slider(value: Binding(
                get: { Double(settings.particleCount) },
                set: { settings.particleCount = Int($0) }
            ), in: 5...50, step: 5)
            .accentColor(settings.accentColor.color)
        }
    }
    
    private var resetButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                settings.resetToDefaults()
            }
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.red)
                    .frame(width: 20)
                
                Text("Restaurer par défaut")
                    .foregroundColor(.red)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var toggleAdvancedButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showAdvancedSettings.toggle()
            }
        }) {
            HStack {
                Image(systemName: showAdvancedSettings ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
                
                Text(showAdvancedSettings ? "Masquer avancé" : "Afficher avancé")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .background(settings.accentColor.gradient)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.ultraThinMaterial)
    }
}
