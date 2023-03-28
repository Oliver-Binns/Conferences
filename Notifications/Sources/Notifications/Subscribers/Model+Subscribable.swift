import CloudKit
import Model
import Service

extension Conference: Subscribable {
    public static var info: CKSubscription.NotificationInfo {
        let info = CKSubscription.NotificationInfo()
        info.titleLocalizationKey = "New Conference: %1$@"
        info.titleLocalizationArgs = ["name"]

        info.alertLocalizationKey = "Open the app for more details including dates and location!"

        info.shouldBadge = true
        info.soundName = "default"
        return info
    }
}
extension Attendance: Subscribable { }
