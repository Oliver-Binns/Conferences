import CoreData
import Model

extension NSManagedObjectModel {
    static var conferences: NSManagedObjectModel {
        NSManagedObjectModel(contentsOf: url)!
    }

    private static var url: URL {
        guard let modelURL = Model.bundle
            .url(forResource: "Conferences", withExtension: "momd") else {
            preconditionFailure("Unable to find CoreData model in bundle")
        }
        return modelURL
    }
}
