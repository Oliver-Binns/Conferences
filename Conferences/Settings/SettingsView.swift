import CoreData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var subscriber: NotificationSettingsViewModel

    init(dataStore: ConferenceDataStore, viewContext: NSManagedObjectContext) {
        _subscriber = .init(initialValue:
            NotificationSettingsViewModel(context: viewContext, database: dataStore)
        )
    }

    var body: some View {
        NavigationView {
            List {
                NotificationsView(notificationSubscriber: subscriber)
            
                NavigationLink("About the App") {
                    InfoView()
                }
            }
        }.toolbar {
            Button {
                dismiss()
            } label: {
                Text("Done")
            }
        }
    }
}
