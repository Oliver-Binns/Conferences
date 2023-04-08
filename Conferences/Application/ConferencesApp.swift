import Model
import SwiftUI

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
