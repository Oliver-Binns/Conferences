import CloudKit

public struct Subscription {
    let type: SubscriptionType
    let object: Subscribable.Type

    public init(toUpdates type: SubscriptionType,
                subscribable: Subscribable.Type) {
        self.type = type
        self.object = subscribable
    }

    var id: String {
        "\(type.rawValue)\(object.recordType.name)"
            .filter { $0.isLetter }
    }
}

public enum SubscriptionType: String {
    case new
    case edit
}
