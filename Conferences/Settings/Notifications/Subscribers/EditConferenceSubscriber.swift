import CloudKit

struct EditConferenceSubscriber: ObjectSubscriber {
    private let subscriptionID: String = SubscriptionType.conferenceEdit.rawValue
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
                                               options: .firesOnRecordUpdate)
        try await CKContainer.default().publicCloudDatabase.save(subscription)
    }
    
    func unsubscribe() async throws {
        try await CKContainer.default().publicCloudDatabase
            .deleteSubscription(withID: subscriptionID)
    }
}
