import CoreData
import Model
import Persistence
import SwiftUI

struct PersistenceController {
    static var shared: DataStore = {
        let container = NSPersistentCloudKitContainer(name: "Conferences",
                                                      managedObjectModel: .conferences)
        return CoreDataStore(container: container)
    }()
}

@main
struct ConferencesApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    ConferenceList()
                        .navigationTitle("Conferences")
                }
                .tabItem {
                    Label("Conferences", systemImage: "airplane.departure")
                }
                
                NavigationView {
                    IdeasList()
                        .navigationTitle("Brainstorm")
                }
                .tabItem {
                    Label("Brainstorm", systemImage: "lightbulb.fill")
                }
            }
            .environment(\.managedObjectContext, PersistenceController.shared.context)
            .environmentObject(CachedService<Conference>())
        }
    }
}
