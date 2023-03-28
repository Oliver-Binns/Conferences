public protocol NotificationManager {
    var state: NotificationsState { get set }
}

public protocol NotificationsState {
    var newConferences: Bool { get set }
    var travel: Bool { get set }
    var cfpOpening: Bool { get set }
    var cfpClosing: Bool { get set }
}
