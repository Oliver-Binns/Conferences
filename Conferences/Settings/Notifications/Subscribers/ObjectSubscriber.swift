protocol ObjectSubscriber {
    var isSubscribed: Bool { get async throws }
    func subscribe() async throws
    func unsubscribe() async throws
}

enum SubscriptionType: String {
    case newConferences
    case conferenceEdit
    case attendanceEdit
}
