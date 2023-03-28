import CloudKit

public protocol SubscriptionService {
    func isSubscribed(subscription: Subscription) async throws -> Bool
    func subscribe(_ subscription: Subscription) async throws
    func unsubscribe(_ subscription: Subscription) async throws
}
