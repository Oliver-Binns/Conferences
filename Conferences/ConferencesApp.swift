import SwiftUI

@main
struct ConferencesApp: App {
    let persistenceController = PersistenceController.shared

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
            .environment(\.managedObjectContext,
                          persistenceController.container.viewContext)
        }
    }
}
