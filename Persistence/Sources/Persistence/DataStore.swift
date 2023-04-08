import CoreData

public protocol DataStore {
    var context: NSManagedObjectContext { get }
}
