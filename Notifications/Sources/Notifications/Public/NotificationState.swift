import Combine

public protocol NotificationState: ObservableObject {
    var isDenied: Bool { get }

    var newConference: Bool { get set }
    var cfpOpening: Bool { get set }
    var cfpClosing: Bool { get set }
    var travel: Bool { get set }
}
