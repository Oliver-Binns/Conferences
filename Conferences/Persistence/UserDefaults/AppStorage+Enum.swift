import SwiftUI

extension AppStorage {
    init(wrappedValue: Value,
         _ key: SettingsKey,
         store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
