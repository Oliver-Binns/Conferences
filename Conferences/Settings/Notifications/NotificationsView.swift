import Notifications
import Service
import SwiftUI

struct NotificationsView: View {
    @StateObject
    var state = NotificationManager(scheduler:
        NotificationScheduler(service: CloudKitService.shared, store: PersistenceController.shared)
    )

    private let urlOpener: URLOpener = UIApplication.shared
    
    var body: some View {
        Section("Notifications") {
            if state.newConference != nil {
                Toggle("New Conferences",
                       isOn: .init(get: { state.newConference ?? false },
                                   set: { state.newConference = $0 }))
                .disabled(state.isDenied)
            } else {
                HStack {
                    Text("New Conferences")
                    Spacer()
                    ProgressView()
                }
            }



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
