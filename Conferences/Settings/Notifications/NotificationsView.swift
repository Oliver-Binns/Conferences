import SwiftUI

struct NotificationsView: View {
    @ObservedObject
    var notificationSubscriber: NotificationSettingsViewModel
    private let urlOpener: URLOpener = UIApplication.shared
    
    var body: some View {
        Section("Notifications") {
            if notificationSubscriber.newConferences != nil {
                Toggle("New Conferences",
                       isOn: .init(get: {
                    notificationSubscriber.newConferences ?? false
                }, set: {
                    notificationSubscriber.newConferences = $0
                }))
                .disabled(notificationSubscriber.isRejected)
            } else {
                HStack {
                    Text("New Conferences")
                    Spacer()
                    ProgressView()
                }
            }
            
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
