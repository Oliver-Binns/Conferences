import CloudKit
import UIKit
import UserNotifications

final class NotificationSubscriber: ObservableObject {
    @MainActor @Published
    private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    @MainActor
    var isRejected: Bool {
        authorizationStatus == .denied
    }
    
    @MainActor @Published
    var newConferences: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
                
                if newConferences {
                    try await subscribeToNewConferences()
                } else {
                    try await removeConferenceSubscription()
                }
            }
        }
    }
    
    @MainActor @Published
    var cfpOpening: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
            }
        }
    }
    
    @MainActor @Published
    var cfpClosing: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
            }
        }
    }
    
    @MainActor @Published
    var travelReminders: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
            }
        }
    }
    
    private let centre: UNUserNotificationCenter
    
    init(centre: UNUserNotificationCenter = .current()) async throws {
        self.centre = centre
        
        let newConferences = try await isConferenceSubscriptionEnabled()
        await MainActor.run { self.newConferences = newConferences }
    }
    
    private func requestAuthorizationIfNeeded() async throws {
        guard await authorizationStatus == .notDetermined else { return }
        try await centre
            .requestAuthorization(options: [.alert, .badge, .sound])
        await checkNotificationSettings()
    }
    
    private func subscribeToNewConferences() async throws {
        let subscription = CKQuerySubscription(recordType: RecordType.conference.rawValue,
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: SubscriptionType.newConferences.rawValue,
                                               options: .firesOnRecordCreation)
        
        let info = CKSubscription.NotificationInfo()
        info.titleLocalizationKey = "New Conference: %1$@"
        info.titleLocalizationArgs = ["name"]
        
        info.alertLocalizationKey = "Open the app for more details including dates and location!"
        
        info.shouldBadge = true
        info.soundName = "default"
        
        subscription.notificationInfo = info
        try await CKContainer.default().publicCloudDatabase.save(subscription)
    }
    
    private func removeConferenceSubscription() async throws {
        try await CKContainer.default().publicCloudDatabase
            .deleteSubscription(withID: SubscriptionType.newConferences.rawValue)
    }
    
    private func isConferenceSubscriptionEnabled() async throws -> Bool {
        do {
            _ = try await CKContainer.default()
                .publicCloudDatabase
                .fetch(withSubscriptionID: SubscriptionType.newConferences.rawValue)
            return true
        } catch CKError.unknownItem {
            return false
        }
    }
    
    func checkNotificationSettings() async {
        let status = await centre.getNotificationSettings()
            .authorizationStatus
        await MainActor.run {
            authorizationStatus = status
        }
    }
}

enum SubscriptionType: String {
    case newConferences
    case conferenceEdit
    case attendanceEdit
}
