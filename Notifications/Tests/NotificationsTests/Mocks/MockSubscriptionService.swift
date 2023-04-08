@testable import Service

final class MockSubscriptionService: SubscriptionService {
    var didSubscribe: [Service.Subscription] = []
    var didUnsubscribe: [Service.Subscription] = []

    func isSubscribed(subscription: Service.Subscription) async throws -> Bool {
        false
    }

    func subscribe(_ subscription: Service.Subscription) async throws {
        didSubscribe.append(subscription)
    }

    func unsubscribe(_ subscription: Service.Subscription) async throws {
        didUnsubscribe.append(subscription)
    }
}
