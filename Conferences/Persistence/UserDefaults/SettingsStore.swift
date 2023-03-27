import Foundation

enum SettingsKey: String {
    case cfpOpenNotifications
    case cfpCloseNotifications
    case travelNotifications
}

protocol SettingsStore {
    func bool(for key: SettingsKey) -> Bool
}
extension UserDefaults: SettingsStore {
    func bool(for key: SettingsKey) -> Bool {
        bool(forKey: key.rawValue)
    }
}
