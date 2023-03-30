import CoreData
import Model
import Persistence

struct MockDataStore: DataStore {
    private let store: DataStore = PreviewDataStore(container: .conferences)

    var context: NSManagedObjectContext {
        store.context
    }

    func insert(object: NSManagedObject) throws {
        store.context.insert(object)
        try store.context.save()
    }
}
