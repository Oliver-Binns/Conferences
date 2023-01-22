import UserNotifications

extension UNUserNotificationCenter {
    func getNotificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            getNotificationSettings { settings in
                continuation.resume(with: .success(settings))
            }
        }
    }
    
    @discardableResult
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.requestAuthorization(options: options,
                                      completionHandler: { success, error in
                if let error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume(with: .success(success))
                }
            })
        }
    }
}
