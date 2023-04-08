import Foundation

enum SettingsKey: String {
    case cfpOpenNotifications
    case cfpCloseNotifications
    case travelNotifications
}

protocol SettingsStore {
    func bool(for key: SettingsKey) -> Bool
    func set(value: Bool, for key: SettingsKey)
}
extension UserDefaults: SettingsStore {
    func bool(for key: SettingsKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    func set(value: Bool, for key: SettingsKey) {
        setValue(value, forKey: key.rawValue)
    }
}
