import CoreData
import Foundation

// MARK: - TodoItem Extension
extension TodoItem {
    var subtasksArray: [SubtaskItem] {
        let set = subtasks as? Set<SubtaskItem> ?? []
        return set.sorted {
            $0.sortOrder < $1.sortOrder
        }
    }

    var completedSubtasksCount: Int {
        subtasksArray.filter { $0.isCompleted }.count
    }

    var totalSubtasksCount: Int {
        subtasksArray.count
    }

    var progressPercentage: Double {
        guard totalSubtasksCount > 0 else { return 0 }
        return Double(completedSubtasksCount) / Double(totalSubtasksCount)
    }
}

// MARK: - SubtaskItem Extension
extension SubtaskItem {
    // Méthodes utilitaires pour les sous-tâches si nécessaire
}
