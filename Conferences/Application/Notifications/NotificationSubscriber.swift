import CloudKit
import UIKit
import UserNotifications

@MainActor
final class NotificationSubscriber: ObservableObject {
    @Published
    private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    var isRejected: Bool {
        authorizationStatus == .denied
    }
    
    @Published
    var newConferences: Bool {
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
    
    @Published
    var cfpOpening: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
            }
        }
    }
    
    @Published
    var cfpClosing: Bool = false {
        didSet {
            Task {
                try await requestAuthorizationIfNeeded()
            }
        }
    }
    
    @Published
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
        self.newConferences = try await Self.isConferenceSubscriptionEnabled()
    }
    
    private func requestAuthorizationIfNeeded() async throws {
        guard authorizationStatus == .notDetermined else { return }
        try await centre
            .requestAuthorization(options: [.alert, .badge, .sound])
        authorizationStatus = await centre.getNotificationSettings().authorizationStatus
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
    
    private static func isConferenceSubscriptionEnabled() async throws -> Bool {
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
        authorizationStatus = await centre.getNotificationSettings()
            .authorizationStatus
    }
}

enum SubscriptionType: String {
    case newConferences
    case conferenceEdit
    case attendanceEdit
}
