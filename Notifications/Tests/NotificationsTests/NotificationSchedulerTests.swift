import CoreLocation
import Model
import XCTest
@testable import Notifications

final class NotificationSchedulerTests: XCTestCase {
    var sut: NotificationScheduler!
    var service: MockDataService!
    var store: MockDataStore!
    var settings: MockSettings!

    var center: MockNotificationCenter!

    override func setUp() {
        super.setUp()

        center = MockNotificationCenter()
        service = MockDataService()
        store = MockDataStore()
        settings = MockSettings()

        sut = .init(center: center,
                    settingsStore: settings,
                    service: service, store: store,
                    parser: .init(service: service, store: store))
    }

    override func tearDown() {
        sut = nil
        service = nil
        store = nil
        center = nil
        settings = nil
        super.tearDown()
    }
}

extension NotificationSchedulerTests {
    func testScheduleCFPOpeningNotificationNoCFP() async throws {
        settings.set(value: true, for: .cfpOpenNotifications)
        service.data = [Conference.mock()]

        try await sut.scheduleCFPOpeningNotifications()
        // cannot schedule a notification for an unknown CFP
        XCTAssertTrue(center.pendingRequests.isEmpty)
    }

    func testScheduleCFPOpeningNotificationsDisabled() async throws {
        settings.set(value: false, for: .cfpOpenNotifications)
        service.data = [Conference.mock(cfpDates: [.distantFuture])]

        // does not schedule a notification when the setting is disabled
        try await sut.scheduleCFPOpeningNotifications()
        XCTAssertEqual(center.pendingRequests.count, 0)
    }

    func testScheduleCFPOpeningNotification() async throws {
        settings.set(value: true, for: .cfpOpenNotifications)
        service.data = [Conference.mock(cfpDates: [.distantFuture])]

        try await sut.scheduleCFPOpeningNotifications()
        XCTAssertEqual(center.pendingRequests.count, 1)

        // notification has been scheduled!
        let request = center.pendingRequests[0]
        XCTAssertEqual(request.content.title, "CFP Now Open")
        XCTAssertEqual(request.content.body, "Submit a talk for Mock Conference now.")
        XCTAssertEqual(request.content.sound, .default)
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
