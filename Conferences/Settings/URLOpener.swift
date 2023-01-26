import UIKit

protocol URLOpener {
    func openNotificationSettings()
}

extension UIApplication: URLOpener {
    func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        open(url)
    }
}
