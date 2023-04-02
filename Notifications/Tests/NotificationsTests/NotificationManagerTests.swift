import XCTest
@testable import Notifications

@MainActor
final class NotificationManangerTests: XCTestCase {
    var sut: NotificationManager!

    var service: MockSubscriptionService!
    var center: MockNotificationCenter!
    var settings: MockSettings!

    override func setUp() {
        super.setUp()

        service = MockSubscriptionService()
        settings = MockSettings()
        center = MockNotificationCenter()

        let parser = NotificationParser(service: MockDataService(),
                                        store: MockDataStore())
        let scheduler = NotificationScheduler(center: center,
                                              settingsStore: settings,
                                              service: MockDataService(),
                                              store: MockDataStore(),
                                              parser: parser)

        sut = .init(scheduler: scheduler,
                    service: service,
                    store: settings,
                    center: center)
    }

    override func tearDown() {
        sut = nil
        service = nil
        settings = nil
        center = nil

        super.tearDown()
    }
}

extension NotificationManangerTests {
    func testDidEnableNewConferenceRequestsAuthorization() {
        sut.newConference = true
        wait(for: self.center.didCallRequestAuthorization, timeout: 3)
    }

    func testDidEnableCFPOpeningRequestsAuthorization() {
        sut.cfpOpening = true
        wait(for: self.center.didCallRequestAuthorization, timeout: 3)
    }

    func testDidEnableCFPClosingRequestsAuthorization() {
        sut.cfpClosing = true
        wait(for: self.center.didCallRequestAuthorization, timeout: 3)
    }

    func testDidEnableTravelRequestsAuthorization() {
        sut.travel = true
        wait(for: self.center.didCallRequestAuthorization, timeout: 3)
    }
}
