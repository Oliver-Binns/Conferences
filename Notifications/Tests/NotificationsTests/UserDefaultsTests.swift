@testable import Notifications
import Foundation
import XCTest

final class UserDefaultsTests: XCTestCase {
    let sut = UserDefaults.standard

    func testGetBoolean() {
        sut.set(true, forKey: "travelNotifications")
        XCTAssertTrue(sut.bool(for: .travelNotifications))

        sut.set(false, forKey: "cfpOpenNotifications")
        XCTAssertFalse(sut.bool(for: .cfpOpenNotifications))
    }

    func testSetBoolean() {
        sut.set(value: false, for: .travelNotifications)
        XCTAssertEqual(sut.value(forKey: "travelNotifications") as? Bool, false)

        sut.set(value: true, for: .cfpOpenNotifications)
        XCTAssertEqual(sut.value(forKey: "cfpOpenNotifications") as? Bool, true)
    }
}
