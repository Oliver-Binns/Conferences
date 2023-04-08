@testable import Notifications
@testable import Service
import XCTest

final class PersistenceSubscriberTests: XCTestCase {
    func testIDs() {
        XCTAssertEqual(
            PersistenceSubscriber
                .newConference(service: MockSubscriptionService()).subscription.id,
            "newConference"
        )
        XCTAssertEqual(
            PersistenceSubscriber
                .editConference(service: MockSubscriptionService()).subscription.id,
            "editConference"
        )
        XCTAssertEqual(
            PersistenceSubscriber
                .editAttendance(service: MockSubscriptionService()).subscription.id,
            "editCDAttendance"
        )
    }
}
