import UserNotifications
@testable import Notifications

final class MockNotificationCenter: NSObject, Notifications.NotificationCenter {
    var didCallRequestAuthorization = false

    var authorizationStatus: UNAuthorizationStatus {
        .notDetermined
    }

    var pendingRequests: [UNNotificationRequest] = []

    var didCallRemoveNotifications: [String] = []

    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        pendingRequests
    }

    func add(_ request: UNNotificationRequest) async throws {
        pendingRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        didCallRemoveNotifications.append(contentsOf: identifiers)
    }

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        didCallRequestAuthorization = true
        return false
    }
}
