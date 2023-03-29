import Notifications
import Service
import SwiftUI

struct NotificationsView: View {
    @ObservedObject
    var state = NotificationManager(scheduler:
        NotificationScheduler(service: CloudKitService.shared, store: PersistenceController.shared)
    )

    private let urlOpener: URLOpener = UIApplication.shared
    
    var body: some View {
        Section("Notifications") {
            Toggle("New Conferences",
                   isOn: $state.newConference)
            .disabled(state.isDenied)

            Toggle("Travel Reminders",
                   isOn: $state.travel)
            .disabled(state.isDenied)
            
            Toggle("CFP Opening",
                   isOn: $state.cfpOpening)
            .disabled(state.isDenied)

            Toggle("CFP Closing",
                   isOn: $state.cfpClosing)
            .disabled(state.isDenied)
            
            if state.isDenied {
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        urlOpener.openNotificationSettings()
                    } label: {
                        Label("To receive notifications, you must grant the permission using the Settings app.",
                              systemImage: "gear")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
            }
        }
    }
}
