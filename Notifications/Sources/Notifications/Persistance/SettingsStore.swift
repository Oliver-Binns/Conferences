import Foundation

public enum SettingsKey: String {
    case cfpOpenNotifications
    case cfpCloseNotifications
    case travelNotifications
}

public protocol SettingsStore {
    func bool(for key: SettingsKey) -> Bool
}
extension UserDefaults: SettingsStore {
    public func bool(for key: SettingsKey) -> Bool {
        bool(forKey: key.rawValue)
    }
}
