import CloudKit
import Model
import Service

struct PersistenceSubscriber: ObjectSubscriber {
    let subscription: Subscription
    let service: SubscriptionService
    
    var isSubscribed: Bool {
        get async throws {
            try await service.isSubscribed(subscription: subscription)
        }
    }
    
    func subscribe() async throws {
        try await service.subscribe(subscription)
    }
    
    func unsubscribe() async throws {
        try await service.unsubscribe(subscription)
    }
}

extension PersistenceSubscriber {
    static func editAttendance(service: SubscriptionService = CloudKitService.shared) -> Self {
        let subscription = Subscription(toUpdates: .edit, subscribable: Attendance.self)
        return .init(subscription: subscription, service: service)
    }

    static func editConference(service: SubscriptionService = CloudKitService.shared) -> Self {
        let subscription = Subscription(toUpdates: .edit, subscribable: Conference.self)
        return .init(subscription: subscription, service: service)
    }

    static func newConference(service: SubscriptionService = CloudKitService.shared) -> Self {
        let subscription = Subscription(toUpdates: .new, subscribable: Conference.self)
        return .init(subscription: subscription, service: service)
    }
}
