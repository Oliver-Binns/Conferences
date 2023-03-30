import CoreData
import Model
import Persistence

struct PersistenceController {
    static var shared: DataStore = {
        CoreDataStore(container: .conferences)
    }()
}

#if DEBUG
extension PersistenceController {
    static var preview: DataStore = {
        let result = PreviewDataStore(container: .conferences)

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
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()
}

#endif
