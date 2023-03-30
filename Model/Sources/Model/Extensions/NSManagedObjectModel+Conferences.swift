import CoreData

extension NSManagedObjectModel {
    static var conferences: NSManagedObjectModel {
        NSManagedObjectModel(contentsOf: url)!
    }

    private static var url: URL {
        guard let modelURL = Bundle.module
            .url(forResource: "Conferences", withExtension: "momd") else {
            preconditionFailure("Unable to find CoreData model in bundle")
        }
        return modelURL
    }
}

extension NSPersistentContainer {
    public static var conferences: NSPersistentContainer {
        NSPersistentCloudKitContainer(name: "Conferences", managedObjectModel: .conferences)
    }
}
