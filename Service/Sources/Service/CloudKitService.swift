import CloudKit

public struct CloudKitService {
    private let container = CKContainer.default()

    public static let shared = CloudKitService()
}

extension CloudKitService: DataService {
    public func retrieve<T: Queryable>() async throws -> [T] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: T.recordType.name, predicate: predicate)

        return try await container[keyPath: T.recordType.database]
            .run(query: query)
            .compactMap { try? await T(record: $0, database: self) }
            .reduce(into: [T](), {
                $0.append($1)
            })
    }


    public func retrieve<T: Queryable>(id: CKRecord.ID) async throws -> T? {
        guard let record = try await container[keyPath: T.recordType.database]
            .fetch(withRecordID: id) else {
            return nil
        }
        return try await T(record: record, database: self)
    }
}

extension CloudKitService: SubscriptionService {
    public func isSubscribed(subscription: Subscription) async throws -> Bool {
        do {
            _ = try await container[keyPath: subscription.object.recordType.database]
                .fetch(withSubscriptionID: subscription.id)
            return true
        } catch CKError.unknownItem {
            return false
        }
    }

    public func subscribe(_ sub: Subscription) async throws {
        let options: CKQuerySubscription.Options =
            sub.type == .edit ?
            .firesOnRecordUpdate :
            .firesOnRecordCreation

        let subscription =  CKQuerySubscription(recordType: sub.object.recordType.name,
                                                predicate: NSPredicate(value: true),
                                                subscriptionID: sub.id,
                                                options: options)
        subscription.notificationInfo = sub.object.info

        try await container[keyPath: sub.object.recordType.database]
            .save(subscription)
    }

    public func unsubscribe(_ subscription: Subscription) async throws {
        try await container[keyPath: subscription.object.recordType.database]
            .deleteSubscription(withID: subscription.id)
    }
}
