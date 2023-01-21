import CoreData

extension NSManagedObjectContext {
    var editingContext: NSManagedObjectContext {
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = self
        return childContext
    }
}
