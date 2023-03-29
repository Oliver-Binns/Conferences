import CoreData
import Persistence

struct MockDataStore: DataStore {
    var context: NSManagedObjectContext = .init(concurrencyType: .mainQueueConcurrencyType)
}
