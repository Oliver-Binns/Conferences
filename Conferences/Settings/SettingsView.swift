import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var subscriber: NotificationSettingsViewModel?
    
    var body: some View {
        NavigationView {
            List {
                if let subscriber {
                    NotificationsView(notificationSubscriber: subscriber)
                } else {
                    Section("Notifications") {
                        ProgressView("Loading...")
                    }.task {
                        subscriber = try? await .init()
                    }
                }
            
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
