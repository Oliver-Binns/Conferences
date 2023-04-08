@testable import Notifications

final class MockSettings: SettingsStore {
    private var store: [SettingsKey: Bool] = [:]

    func bool(for key: Notifications.SettingsKey) -> Bool {
        store[key] ?? false
    }

    func set(value: Bool, for key: Notifications.SettingsKey) {
        store[key] = value
    }
}
