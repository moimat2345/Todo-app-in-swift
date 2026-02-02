import SwiftUI
import CoreData
import Combine
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var settings = AppSettings()
    @StateObject private var celebrationManager = CelebrationManager.shared

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TodoItem.sortOrder, ascending: true)],
        animation: .default)
    private var items: FetchedResults<TodoItem>
    
    @State private var newTodoText = ""
    @State private var filter: FilterType = .all
    @State private var showSettings = false
    @State private var showDeleteAlert = false
    @State private var itemToDelete: TodoItem?
    @State private var isAddingItem = false
    @State private var celebrationOffset: CGFloat = 0
    @State private var pulseAnimation = false
    @State private var particleTrigger = 0
    
    var filteredItems: [TodoItem] {
        switch filter {
        case .all:
            return Array(items)
        case .active:
            return items.filter { !$0.isCompleted }
        case .completed:
            return items.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    addTodoSection
                    statsSection
                    filterSection
                    todoListSection
                }
            }
            
            if celebrationManager.showCelebration {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
                
                SuccessCelebration(
                    onComplete: {
                        celebrationManager.hideCelebration()
                    }
                )
                .zIndex(999)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .environmentObject(settings)
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        .frame(minWidth: 600, minHeight: 700)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
        }
        .alert("Supprimer la tâche", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) { }
            Button("Supprimer", role: .destructive) {
                if let item = itemToDelete {
                    deleteItem(item)
                }
            }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer cette tâche ?")
        }
    }
    
    private var backgroundGradient: some View {
        settings.accentColor.gradient
            .opacity(settings.isDarkMode ? 0.3 : 0.1)
            .overlay(
                Group {
                    if settings.particlesEnabled {
                        ParticleBackgroundView(
                            accentColor: settings.accentColor.color,
                            animationSpeed: settings.animationSpeed,
                            particleCount: settings.particleCount,
                            trigger: particleTrigger
                        )
                    }
                }
            )
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("To-Do App")
                        .font(.system(size: 32 * settings.fontSize.multiplier, weight: .bold, design: .rounded))
                        .foregroundStyle(settings.accentColor.gradient)
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    
                    Text("Organisez vos tâches avec style et simplicité !")
                        .font(.system(size: 18 * settings.fontSize.multiplier, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundStyle(settings.accentColor.gradient)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: settings.accentColor.color.opacity(0.3), radius: 10)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .onAppear {
            pulseAnimation = true
        }
    }
    
    private var addTodoSection: some View {
        HStack(spacing: 15) {
            TextField("Ajouter une nouvelle tâche magique...", text: $newTodoText)
                .textFieldStyle(.plain)
                .font(.system(size: 16 * settings.fontSize.multiplier, weight: .medium))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(settings.accentColor.gradient, lineWidth: isAddingItem ? 2 : 0)
                        )
                )
                .scaleEffect(isAddingItem ? 1.02 : 1.0)
                .onSubmit {
                    addItem()
                }
                .onChange(of: newTodoText) { oldValue, newValue in
                    isAddingItem = !newValue.isEmpty
                }
            
            Button(action: addItem) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(settings.accentColor.gradient)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(color: settings.accentColor.color.opacity(0.3), radius: 5)
                    )
                    .scaleEffect(newTodoText.isEmpty ? 0.8 : 1.2)
                    .rotationEffect(.degrees(newTodoText.isEmpty ? 0 : 180))
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(newTodoText.isEmpty)
        }
        .padding()
        .background(.clear)
    }
    
    private var statsSection: some View {
        HStack(spacing: 30) {
            StatCard(
                title: "Actives",
                count: items.filter { !$0.isCompleted }.count,
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Terminées",
                count: items.filter { $0.isCompleted }.count,
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Total",
                count: items.count,
                icon: "list.bullet.circle.fill",
                color: settings.accentColor.color
            )
        }
        .padding()
    }
    
    private var filterSection: some View {
        HStack(spacing: 12) {
            ForEach(FilterType.allCases, id: \.self) { filterType in
                Button(action: {
                    filter = filterType
                    particleTrigger += 1
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: filterType.icon)
                            .font(.system(size: 14, weight: .semibold))
                        Text(filterType.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(filterBackground(for: filterType))
                    .foregroundColor(filter == filterType ? .white : .primary)
                    .scaleEffect(filter == filterType ? 1.05 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(.clear)
    }
    
    private func filterBackground(for filterType: FilterType) -> some View {
        Capsule()
            .fill(filter == filterType ? settings.accentColor.color : Color.gray.opacity(0.2))
    }
    
    private var todoListSection: some View {
        VStack {
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                todoScrollView
            }
        }
        .padding()
        .background(.clear)
    }
    
    private var todoScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredItems.enumerated()), id: \.element.objectID) { index, item in
                    TodoRowView(
                        todo: item,
                        settings: settings,
                        onDelete: { confirmDelete(item) }
                    )
                    .environmentObject(settings)
                    .onDrag {
                        return NSItemProvider(object: item.objectID.uriRepresentation().absoluteString as NSString)
                    }
                    .onDrop(of: [.text], isTargeted: nil) { providers in
                        return handleItemDrop(providers: providers, targetItem: item)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(.spring(duration: 0.6).delay(Double(index) * 0.1), value: filteredItems.count)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: filter == .completed ? "party.popper.fill" : "wand.and.stars")
                .font(.system(size: 60))
                .foregroundStyle(settings.accentColor.gradient)
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            
            Text(emptyStateMessage)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .all:
            return "🌟 Prêt pour une nouvelle aventure ?\nAjoutez votre première tâche magique !"
        case .active:
            return "🎉 Incroyable ! Tout est terminé !\nVous êtes un vrai champion !"
        case .completed:
            return "🚀 Aucune mission accomplie... encore !\nC'est le moment de briller !"
        }
    }
    
    // MARK: - Drag & Drop Actions
    private func handleItemDrop(providers: [NSItemProvider], targetItem: TodoItem) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadObject(ofClass: NSString.self) { (string, error) in
            guard let uriString = string as? String,
                  let uri = URL(string: uriString),
                  let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri),
                  let draggedObject = try? viewContext.existingObject(with: objectID) as? TodoItem else {
                return
            }
            
            DispatchQueue.main.async {
                let allItems = Array(items)
                guard let sourceIndex = allItems.firstIndex(where: { $0.objectID == draggedObject.objectID }),
                      let targetIndex = allItems.firstIndex(where: { $0.objectID == targetItem.objectID }) else {
                    return
                }
                
                reorderItems(from: sourceIndex, to: targetIndex)
            }
        }
        
        return true
    }
    
    private func reorderItems(from sourceIndex: Int, to targetIndex: Int) {
        var allItems = Array(items)
        let movedItem = allItems.remove(at: sourceIndex)
        
        let insertionIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        allItems.insert(movedItem, at: insertionIndex)
        
        // Mettre à jour les sortOrder
        for (index, item) in allItems.enumerated() {
            item.sortOrder = Int32(index)
        }
        
        do {
            try viewContext.save()
            
            if settings.soundEnabled {
                NSSound(named: "Pop")?.play()
            }
            
            if settings.hapticEnabled {
                let impactFeedback = NSHapticFeedbackManager.defaultPerformer
                impactFeedback.perform(.alignment, performanceTime: .default)
            }
        } catch {
            print("Erreur lors de la réorganisation: \(error)")
        }
    }
    
    // MARK: - Actions
    private func addItem() {
        guard !newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newItem = TodoItem(context: viewContext)
        newItem.timestamp = Date()
        newItem.text = newTodoText.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.isCompleted = false
        newItem.sortOrder = Int32(items.count)
        
        do {
            try viewContext.save()
            newTodoText = ""
            isAddingItem = false
            
            if settings.soundEnabled {
                NSSound(named: "Glass")?.play()
            }
        } catch {
            print("Erreur lors de l'ajout: \(error)")
        }
    }

    private func confirmDelete(_ item: TodoItem) {
        itemToDelete = item
        showDeleteAlert = true
    }
    
    private func deleteItem(_ item: TodoItem) {
        viewContext.delete(item)
        
        do {
            try viewContext.save()
            
            if settings.soundEnabled {
                NSSound(named: "Funk")?.play()
            }
        } catch {
            print("Erreur lors de la suppression: \(error)")
        }
    }
}

// MARK: - StatCard
struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
