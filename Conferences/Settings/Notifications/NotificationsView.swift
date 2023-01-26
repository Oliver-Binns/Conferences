import SwiftUI

struct NotificationsView: View {
    @ObservedObject var notificationSubscriber: NotificationSettingsViewModel
    private let urlOpener: URLOpener = UIApplication.shared
    
    var body: some View {
        Section("Notifications") {
            Toggle("New Conferences",
                   isOn: $notificationSubscriber.newConferences)
            .disabled(notificationSubscriber.isRejected)
            
            Toggle("Travel Reminders",
                   isOn: $notificationSubscriber.travelReminders)
            .disabled(notificationSubscriber.isRejected)
            
            Toggle("CFP Opening",
                   isOn: $notificationSubscriber.cfpOpening)
            .disabled(notificationSubscriber.isRejected)
            Toggle("CFP Closing",
                   isOn: $notificationSubscriber.cfpClosing)
            .disabled(notificationSubscriber.isRejected)
            
            if notificationSubscriber.isRejected {
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
        .onForeground {
            // TODO: move this inside subscriber class
            Task {
                await notificationSubscriber
                    .checkNotificationSettings()
            }
        }
    }
}
