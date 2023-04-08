import CloudKit

public protocol Subscribable {
    static var recordType: RecordType { get }
    static var info: CKSubscription.NotificationInfo { get }
}

extension Subscribable {
    public static var info: CKSubscription.NotificationInfo {
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        return info
    }
}
