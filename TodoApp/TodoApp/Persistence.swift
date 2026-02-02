import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Créer des données de test
        let sampleTodo1 = TodoItem(context: viewContext)
        sampleTodo1.text = "Acheter du lait"
        sampleTodo1.timestamp = Date()
        sampleTodo1.isCompleted = false
        sampleTodo1.sortOrder = 0

        let sampleTodo2 = TodoItem(context: viewContext)
        sampleTodo2.text = "Finir le projet"
        sampleTodo2.timestamp = Date()
        sampleTodo2.isCompleted = true
        sampleTodo2.sortOrder = 1
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Erreur CoreData: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TodoApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
