protocol ObjectSubscriber {
    var isSubscribed: Bool { get async throws }
    func subscribe() async throws
    func unsubscribe() async throws
}
