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

// MARK: - CFP Opening Notification
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
        XCTAssertTrue(center.pendingRequests.isEmpty)
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

        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertEqual(trigger.nextTriggerDate(), .distantFuture)
        XCTAssertFalse(trigger.repeats)
    }
}

// MARK: - CFP Closing Notifications
extension NotificationSchedulerTests {
    func testScheduleCFPClosingNotificationNoCFP() async throws {
        settings.set(value: true, for: .cfpCloseNotifications)
        service.data = [Conference.mock(cfpDates: [.distantFuture])]

        try await sut.scheduleCFPClosingNotifications()
        // cannot schedule a notification CFP with no close date
        XCTAssertTrue(center.pendingRequests.isEmpty)
    }

    func testScheduleCFPClosingNotificationsDisabled() async throws {
        settings.set(value: false, for: .cfpCloseNotifications)
        service.data = [Conference.mock(cfpDates: [.distantPast, .distantFuture])]

        // does not schedule a notification when the setting is disabled
        try await sut.scheduleCFPClosingNotifications()
        XCTAssertTrue(center.pendingRequests.isEmpty)
    }

    func testScheduleCFPClosingNotification() async throws {
        settings.set(value: true, for: .cfpCloseNotifications)
        service.data = [Conference.mock(cfpDates: [.distantPast, .distantFuture])]

        // does not schedule a notification when the setting is disabled
        try await sut.scheduleCFPClosingNotifications()
        XCTAssertEqual(center.pendingRequests.count, 1)

        // notification has been scheduled!
        let request = center.pendingRequests[0]
        XCTAssertEqual(request.content.title, "CFP Closing Soon")
        XCTAssertEqual(request.content.body, "Submit a talk for Mock Conference now.")
        XCTAssertEqual(request.content.sound, .default)

        let threeDaysEarly = Calendar.current.date(byAdding: .day, value: -3, to: .distantFuture)
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertEqual(trigger.nextTriggerDate(), threeDaysEarly)
        XCTAssertFalse(trigger.repeats)
    }
}

// MARK: - Travel Reminders
extension NotificationSchedulerTests {
    func testScheduleTravelNotificationTravelAlreadyBooked() async throws {
        settings.set(value: true, for: .travelNotifications)

        _ = try createConference(travelBooked: true)

        try await sut.scheduleTravelNotifications()
        // cannot schedule a notification CFP with no close date
        XCTAssertTrue(center.pendingRequests.isEmpty)
    }

    func testScheduleTravelNotificationNotAttending() async throws {
        settings.set(value: true, for: .travelNotifications)

        _ = try createConference(attendanceType: .none)

        try await sut.scheduleTravelNotifications()
        // cannot schedule a notification CFP with no close date
        XCTAssertTrue(center.pendingRequests.isEmpty)
    }

    func testScheduleTravelNotificationsDisabled() async throws {
        settings.set(value: false, for: .travelNotifications)
        _ = try createConference()

        // does not schedule a notification when the setting is disabled
        try await sut.scheduleTravelNotifications()
        XCTAssertTrue(center.pendingRequests.isEmpty)
    }

    func testScheduleTravelNotification() async throws {
        settings.set(value: true, for: .travelNotifications)
        let conference = try createConference()

        // does not schedule a notification when the setting is disabled
        try await sut.scheduleTravelNotifications()
        XCTAssertEqual(center.pendingRequests.count, 1)

        // notification has been scheduled!
        let request = center.pendingRequests[0]
        XCTAssertEqual(request.content.title, "Mock Conference is approaching")
        XCTAssertEqual(request.content.body, "Have you booked your travel yet?")
        XCTAssertEqual(request.content.sound, .default)

        let components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second],
                                                         from: conference.dates.lowerBound)
        let sanitisedDate = try XCTUnwrap(Calendar.current.date(from: components))
        let fireDate = Calendar.current
            .date(byAdding: .day, value: -45, to: sanitisedDate)
        
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertEqual(trigger.nextTriggerDate(), fireDate)
        XCTAssertFalse(trigger.repeats)
    }

    func createConference(travelBooked: Bool = false, attendanceType: AttendanceType = .attendee) throws -> Conference {
        let conferenceID = UUID()
        let conference = Conference.mock(id: conferenceID, cfpDates: [.distantPast, .distantFuture])

        let attendance = CDAttendance(context: store.context)
        attendance.travelBooked = travelBooked
        attendance.type = attendanceType.rawValue
        attendance.conferenceId = conferenceID.uuidString
        try store.insert(object: attendance)

        service.data = [
            conference
        ]

        return conference
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
