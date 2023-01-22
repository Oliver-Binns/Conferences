import CloudKit

struct EditAttendanceSubscriber: ObjectSubscriber {
    private let subscriptionID: String = SubscriptionType.attendanceEdit.rawValue
    private let database: CKDatabase
    
    var isSubscribed: Bool {
        get async throws {
            do {
                _ = try await CKContainer.default()
                    .privateCloudDatabase
                    .fetch(withSubscriptionID: subscriptionID)
                return true
            } catch CKError.unknownItem {
                return false
            }
        }
    }
    
    init(database: CKDatabase = CKContainer.default().privateCloudDatabase) {
        self.database = database
    }
    
    func subscribe() async throws {
        let subscription = CKQuerySubscription(recordType: RecordType.attendance.rawValue,
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: subscriptionID,
                                               options: .firesOnRecordUpdate)
        try await database.save(subscription)
    }
    
    func unsubscribe() async throws {
        try await database
            .deleteSubscription(withID: subscriptionID)
    }
}
