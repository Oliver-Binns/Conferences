import CoreData
import Model
import Persistence

#if DEBUG
extension PersistenceController {
    static var preview: DataStore = {
        let container = NSPersistentCloudKitContainer(name: "Conferences")
        let result = CoreDataStore(container: container, inMemory: true)
        let viewContext = result.context
        [
            "Something Something Some Core Data",
            "Something Something Some SwiftUI",
            "Something Something Some WeatherKit",
            "Something Something Some ARKit",
            "Something Something Some Accessibility"
        ].forEach {
            let newItem = CDIdea(context: viewContext)
            newItem.title = $0
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
#endif
