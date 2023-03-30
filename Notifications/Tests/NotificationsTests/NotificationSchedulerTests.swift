import CoreLocation
import Model
import XCTest
@testable import Notifications

final class NotificationSchedulerTests: XCTestCase {
    var sut: NotificationScheduler!
    var service: MockDataService!
    var store: MockDataStore!

    var center: MockNotificationCenter!

    override func setUp() {
        super.setUp()

        center = .init()

        service = MockDataService()
        store = MockDataStore()

        sut = .init(center: center,
                    settingsStore: UserDefaults.standard,
                    service: service, store: store,
                    parser: .init(service: service, store: store))
    }

    override func tearDown() {
        sut = nil
        service = nil
        store = nil
        center = nil
        super.tearDown()
    }
}
// MARK: - Remove Notifications
extension NotificationSchedulerTests {
    func testRemoveCFPOpeningNotifications() async throws {
        let identifiers = (0..<5).map { _ in "\(UUID())-cfpopening" }
        try await addNotifications(identifiers: identifiers)

        await sut.removePendingCFPOpeningNotifications()
        XCTAssertEqual(center.didCallRemoveNotifications, identifiers)
    }

    func testRemovePendingCFPClosingNotifications() async throws {
        let identifiers = (0..<5).map { _ in "\(UUID())-cfpclosing" }
        try await addNotifications(identifiers: identifiers + (0..<5).map { _ in "\(UUID())-cfpopening" })

        await sut.removePendingCFPClosingNotifications()
        XCTAssertEqual(center.didCallRemoveNotifications, identifiers)
    }

    func testRemovePendingTravelNotifications() async throws{
        let identifiers = (0..<5).map { _ in "\(UUID())-travel" }
        try await addNotifications(identifiers: identifiers)

        await sut.removePendingTravelNotifications()
        XCTAssertEqual(center.didCallRemoveNotifications, identifiers)
    }
}

extension NotificationSchedulerTests {
    func addNotifications(identifiers: [String]) async throws {
        center.pendingRequests = identifiers.map {
            let content = UNMutableNotificationContent()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            return UNNotificationRequest(identifier: $0,
                                         content: content,
                                         trigger: trigger)
        }
    }
}
