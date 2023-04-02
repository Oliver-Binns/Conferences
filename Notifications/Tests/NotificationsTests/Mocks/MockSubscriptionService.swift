@testable import Service

final class MockSubscriptionService: SubscriptionService {
    func isSubscribed(subscription: Service.Subscription) async throws -> Bool {
        false
    }

    func subscribe(_ subscription: Service.Subscription) async throws {

    }

    func unsubscribe(_ subscription: Service.Subscription) async throws {

    }
}
