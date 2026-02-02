import SwiftUI
import CoreData
import Combine
import UniformTypeIdentifiers

struct TodoRowView: View {
    @ObservedObject var todo: TodoItem
    @ObservedObject var settings: AppSettings
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditing = false
    @State private var editText = ""
    @State private var showSubtaskInput = false
    @State private var newSubtaskText = ""
    @State private var showSubtasks = true
    @FocusState private var isSubtaskFieldFocused: Bool
    
    @FetchRequest var subtasksFetch: FetchedResults<SubtaskItem>
    
    var onDelete: () -> Void
    
    init(todo: TodoItem, settings: AppSettings, onDelete: @escaping () -> Void) {
        self.todo = todo
        self.settings = settings
        self.onDelete = onDelete
        
        self._subtasksFetch = FetchRequest(
            entity: SubtaskItem.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \SubtaskItem.sortOrder, ascending: true)],
            predicate: NSPredicate(format: "parentTask == %@", todo)
        )
    }
    
    private var subtasks: [SubtaskItem] {
        return Array(subtasksFetch)
    }
    
    private var completionPercentage: Double {
        guard !subtasks.isEmpty else { return todo.isCompleted ? 1.0 : 0.0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mainTaskRow
            
            if !subtasks.isEmpty {
                progressBar
            }
            
            if showSubtasks {
                subtaskSection
            }
        }
        .padding()
        .background(taskBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        .scaleEffect(todo.isCompleted ? 0.98 : 1.0)
        .opacity(todo.isCompleted ? 0.8 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: todo.isCompleted)
    }
    
    private var mainTaskRow: some View {
        HStack(spacing: 15) {
            completionButton
            taskContent
            actionButtons
        }
    }
    
    private var completionButton: some View {
        Button(action: toggleCompletion) {
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(todo.isCompleted ? .green : settings.accentColor.color)
                .scaleEffect(todo.isCompleted ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: todo.isCompleted)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var taskContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEditing {
                editingField
            } else {
                taskText
                taskTimestamp
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var editingField: some View {
        TextField("Modifier la tâche", text: $editText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onSubmit {
                saveEdit()
            }
            .onAppear {
                editText = todo.text ?? ""
            }
    }
    
    private var taskText: some View {
        Text(todo.text ?? "")
            .font(fontForSize(settings.fontSize))
            .fontWeight(.medium)
            .strikethrough(todo.isCompleted)
            .foregroundColor(todo.isCompleted ? .secondary : .primary)
            .animation(.easeInOut(duration: 0.3), value: todo.isCompleted)
    }
    
    private var taskTimestamp: some View {
        Text(formattedDate(todo.timestamp ?? Date()))
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 8) {
            if !subtasks.isEmpty {
                toggleSubtasksButton
            }
            editButton
            deleteButton
        }
    }
    
    private var toggleSubtasksButton: some View {
        Button(action: toggleSubtasksVisibility) {
            Image(systemName: showSubtasks ? "chevron.down" : "chevron.right")
                .foregroundColor(settings.accentColor.color)
                .font(.caption)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var editButton: some View {
        Button(action: toggleEdit) {
            Image(systemName: isEditing ? "checkmark" : "pencil")
                .foregroundColor(isEditing ? .green : settings.accentColor.color)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Progression")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(completionPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(settings.accentColor.color)
            }
            
            ProgressView(value: completionPercentage, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: settings.accentColor.color))
                .scaleEffect(y: 1.5)
        }
        .padding(.top, 8)
    }
    
    private var subtaskSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(subtasksFetch.enumerated()), id: \.element.objectID) { index, subtask in
                SubtaskRowView(
                    subtask: subtask,
                    settings: settings,
                    onUpdate: { }
                )
                .padding(.leading, 16)
                .onDrag {
                    return NSItemProvider(object: subtask.objectID.uriRepresentation().absoluteString as NSString)
                }
                .onDrop(of: [.text], isTargeted: nil) { providers in
                    return handleSubtaskItemDrop(providers: providers, targetSubtask: subtask)
                }
            }
            
            if showSubtaskInput {
                addSubtaskView
            } else {
                addSubtaskButton
            }
        }
        .padding(.top, 8)
    }
    
    private var addSubtaskView: some View {
        VStack(spacing: 12) {
            TextField("Nouvelle sous-tâche", text: $newSubtaskText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .focused($isSubtaskFieldFocused)
                .onSubmit {
                    if !newSubtaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        addSubtask()
                    }
                }
            
            HStack(spacing: 8) {
                Button {
                    addSubtask()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(settings.accentColor.color)
                    .cornerRadius(6)
                }
                .buttonStyle(.borderless)
                .disabled(newSubtaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Button {
                    cancelSubtaskInput()
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Annuler")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                }
                .buttonStyle(.borderless)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var addSubtaskButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showSubtaskInput = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSubtaskFieldFocused = true
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.caption)
                Text("Sous-tâche")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(settings.accentColor.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(settings.accentColor.color.opacity(0.1))
            .cornerRadius(6)
        }
        .buttonStyle(.borderless)
        .padding(.leading, 16)
    }
    
    private var taskBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(todo.isCompleted ? .green.opacity(0.3) : settings.accentColor.color.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var shadowColor: Color {
        todo.isCompleted ? .green.opacity(0.2) : settings.accentColor.color.opacity(0.15)
    }
    
    private var shadowRadius: CGFloat {
        todo.isCompleted ? 8 : 5
    }
    
    private var shadowY: CGFloat {
        todo.isCompleted ? 4 : 2
    }
    
    // MARK: - Drag & Drop pour sous-tâches
    func handleSubtaskItemDrop(providers: [NSItemProvider], targetSubtask: SubtaskItem) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadObject(ofClass: NSString.self) { (string, error) in
            guard let uriString = string as? String,
                  let uri = URL(string: uriString),
                  let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri),
                  let draggedObject = try? viewContext.existingObject(with: objectID) as? SubtaskItem else {
                return
            }
            
            // Vérifier que la sous-tâche appartient à la même tâche parent
            guard draggedObject.parentTask?.objectID == todo.objectID else { return }
            
            DispatchQueue.main.async {
                guard let sourceIndex = subtasks.firstIndex(where: { $0.objectID == draggedObject.objectID }),
                      let targetIndex = subtasks.firstIndex(where: { $0.objectID == targetSubtask.objectID }) else {
                    return
                }
                
                withAnimation(.spring(duration: 0.5)) {
                    reorderSubtasks(from: sourceIndex, to: targetIndex)
                }
            }
        }
        
        return true
    }
    
    func reorderSubtasks(from sourceIndex: Int, to targetIndex: Int) {
        var allSubtasks = subtasks
        let movedSubtask = allSubtasks.remove(at: sourceIndex)
        
        let insertionIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        allSubtasks.insert(movedSubtask, at: insertionIndex)
        
        // Mettre à jour les sortOrder
        for (index, subtask) in allSubtasks.enumerated() {
            subtask.sortOrder = Int32(index)
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
            print("Erreur lors de la réorganisation des sous-tâches: \(error)")
        }
    }
    func toggleSubtasksVisibility() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showSubtasks.toggle()
        }
    }
    
    func addSubtask() {
        let trimmedText = newSubtaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newSubtask = SubtaskItem(context: viewContext)
        newSubtask.text = trimmedText
        newSubtask.isCompleted = false
        newSubtask.timestamp = Date()
        newSubtask.parentTask = todo
        newSubtask.sortOrder = Int32(subtasks.count)
        
        do {
            try viewContext.save()
            newSubtaskText = ""
            showSubtaskInput = false
            isSubtaskFieldFocused = false
            
        } catch {
            print("Erreur lors de l'ajout de sous-tâche: \(error)")
        }
    }
    
    func cancelSubtaskInput() {
        withAnimation(.easeInOut(duration: 0.2)) {
            newSubtaskText = ""
            showSubtaskInput = false
            isSubtaskFieldFocused = false
        }
    }
    
    func toggleCompletion() {
        let wasCompleted = todo.isCompleted
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            todo.isCompleted.toggle()
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Erreur lors de la sauvegarde: \(error)")
        }
        
        // Déclencher les effets seulement quand on complète
        if !wasCompleted && todo.isCompleted {
            // Utiliser le CelebrationManager global
            if settings.celebrationEnabled {
                CelebrationManager.shared.triggerCelebration()
            }
            
            // Vibration
            if settings.hapticEnabled {
                let impactFeedback = NSHapticFeedbackManager.defaultPerformer
                impactFeedback.perform(.levelChange, performanceTime: .default)
            }
            
            // Son
            if settings.soundEnabled {
                NSSound(named: "Glass")?.play()
            }
        }
    }
    
    func toggleEdit() {
        if isEditing {
            saveEdit()
        } else {
            isEditing = true
            editText = todo.text ?? ""
        }
    }
    
    func saveEdit() {
        guard !editText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isEditing = false
            return
        }
        
        todo.text = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try viewContext.save()
        } catch {
            print("Erreur lors de la sauvegarde: \(error)")
        }
        
        isEditing = false
    }
    
    private func fontForSize(_ size: FontSize) -> Font {
        switch size {
        case .small: return .body
        case .medium: return .title3
        case .large: return .title2
        case .extraLarge: return .title
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    private func formattedDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }
}

// MARK: - SubtaskRowView
struct SubtaskRowView: View {
    @ObservedObject var subtask: SubtaskItem
    @ObservedObject var settings: AppSettings
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditing = false
    @State private var editText = ""
    
    let onUpdate: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: toggleCompletion) {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundColor(subtask.isCompleted ? .green : settings.accentColor.color)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isEditing {
                TextField("Modifier la sous-tâche", text: $editText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        saveEdit()
                    }
                    .onAppear {
                        editText = subtask.text ?? ""
                    }
            } else {
                Text(subtask.text ?? "")
                    .font(.body)
                    .strikethrough(subtask.isCompleted)
                    .foregroundColor(subtask.isCompleted ? .secondary : .primary)
            }
            
            Spacer()
            
            Button(action: toggleEdit) {
                Image(systemName: isEditing ? "checkmark" : "pencil")
                    .foregroundColor(isEditing ? .green : settings.accentColor.color)
                    .font(.caption)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: deleteSubtask) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private func toggleCompletion() {
        withAnimation(.easeInOut(duration: 0.2)) {
            subtask.isCompleted.toggle()
        }

        do {
            try viewContext.save()
            onUpdate()
        } catch {
            print("Erreur lors de la sauvegarde: \(error)")
        }

        // Auto-décompléter la tâche parent si on décoche une sous-tâche
        if let parent = subtask.parentTask,
           parent.isCompleted,
           !subtask.isCompleted {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                parent.isCompleted = false
            }
            do {
                try viewContext.save()
            } catch {
                print("Erreur lors de la décomplétion auto: \(error)")
            }
        }

        // Auto-compléter la tâche parent si toutes les sous-tâches sont terminées
        if let parent = subtask.parentTask,
           !parent.isCompleted,
           let siblings = parent.subtasks as? Set<SubtaskItem>,
           !siblings.isEmpty,
           siblings.allSatisfy({ $0.isCompleted }) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                parent.isCompleted = true
            }
            do {
                try viewContext.save()
            } catch {
                print("Erreur lors de la complétion auto: \(error)")
            }

            if settings.celebrationEnabled {
                CelebrationManager.shared.triggerCelebration()
            }
            if settings.hapticEnabled {
                let impactFeedback = NSHapticFeedbackManager.defaultPerformer
                impactFeedback.perform(.levelChange, performanceTime: .default)
            }
            if settings.soundEnabled {
                NSSound(named: "Glass")?.play()
            }
        }
    }
    
    private func toggleEdit() {
        if isEditing {
            saveEdit()
        } else {
            isEditing = true
            editText = subtask.text ?? ""
        }
    }
    
    private func saveEdit() {
        guard !editText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isEditing = false
            return
        }
        
        subtask.text = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try viewContext.save()
        } catch {
            print("Erreur lors de la sauvegarde: \(error)")
        }
        
        isEditing = false
    }
    
    private func deleteSubtask() {
        viewContext.delete(subtask)
        
        do {
            try viewContext.save()
            onUpdate()
        } catch {
            print("Erreur lors de la suppression: \(error)")
        }
    }
}
