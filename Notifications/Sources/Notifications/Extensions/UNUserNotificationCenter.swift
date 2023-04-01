import UserNotifications

protocol NotificationCenter {
    var authorizationStatus: UNAuthorizationStatus { get async }

    func pendingNotificationRequests() async -> [UNNotificationRequest]
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers: [String])

    @discardableResult
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
}

extension UNUserNotificationCenter: NotificationCenter {
    var authorizationStatus: UNAuthorizationStatus {
        get async {
            await getNotificationSettings().authorizationStatus
        }
    }
}
