import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var subscriber = NotificationSettingsViewModel()
    
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
