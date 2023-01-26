import CloudKit

struct NewConferenceSubscriber: ObjectSubscriber {
    private let subscriptionID: String = SubscriptionType.newConferences.rawValue
    private let database: CKDatabase
    
    var isSubscribed: Bool {
        get async throws {
            do {
                _ = try await CKContainer.default()
                    .publicCloudDatabase
                    .fetch(withSubscriptionID: subscriptionID)
                return true
            } catch CKError.unknownItem {
                return false
            }
        }
    }
    
    init(database: CKDatabase = CKContainer.default().publicCloudDatabase) {
        self.database = database
    }
    
    func subscribe() async throws {
        let subscription = CKQuerySubscription(recordType: RecordType.conference.rawValue,
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: subscriptionID,
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
    
    func unsubscribe() async throws {
        try await CKContainer.default().publicCloudDatabase
            .deleteSubscription(withID: subscriptionID)
    }
}
