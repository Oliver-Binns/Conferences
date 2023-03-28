import SwiftUI

extension AppStorage {
    init<Key: RawRepresentable>(wrappedValue: Value,
                                _ key: Key,
                                store: UserDefaults? = nil) where Value == Bool, Key.RawValue == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
