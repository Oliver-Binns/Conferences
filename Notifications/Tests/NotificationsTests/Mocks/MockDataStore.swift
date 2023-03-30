import CoreData
import Model
import Persistence

struct MockDataStore: DataStore {
    private let store: DataStore = PreviewDataStore(container: .conferences)

    var context: NSManagedObjectContext {
        store.context
    }
}
