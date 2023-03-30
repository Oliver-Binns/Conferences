import CoreData

#if DEBUG
public final class PreviewDataStore: DataStore {
    private let container: NSPersistentContainer
    
    public var context: NSManagedObjectContext {
        container.viewContext
    }

    public init(container: NSPersistentContainer) {
        self.container = container
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
#endif
