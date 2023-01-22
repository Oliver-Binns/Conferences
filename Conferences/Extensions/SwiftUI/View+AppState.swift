import SwiftUI

extension View {
    func onForeground(_ f: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
                  perform: { _ in f() })
    }
}
