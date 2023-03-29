
import XCTest
@testable import Notifications

final class NotificationParserTests: XCTestCase {
    var sut: NotificationParser!

    override func setUp() {
        super.setUp()

        let service = MockDataService()
        let store = MockDataStore()

        sut = .init(service: service, store: store)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testParsingInvalidNotification() async throws {
        do {
            let invalidUserInfo: [AnyHashable: Any] = [:]
            _ = try await sut.parse(userInfo: invalidUserInfo)

            XCTFail("Expected invalid user info error to be thrown")
        } catch NotificationParseError.invalidUserInfo {

        }
    }

    func testParsingInvalidSubscriptionID() async throws {
        do {
            let userInfo = validPayload(id: "abv", subscriptionID: "def")
            _ = try await sut.parse(userInfo: userInfo)

            XCTFail("Expected invalid subscription error to be thrown")
        } catch NotificationParseError.invalidSubscriptionType {

        }
    }

    func testEditAttendanceWithUnknownConference() async throws {
        do {
            let userInfo = validPayload(id: "abv",
                                        subscriptionID: "editAttendance")
            _ = try await sut.parse(userInfo: userInfo)

            XCTFail("Expected missing conference error to be thrown")
        } catch NotificationParseError.noConferenceFound {

        }
    }

    func testEditConferenceWithUnknownConference() async throws {
        do {
            let userInfo = validPayload(id: "abv",
                                        subscriptionID: "editConference")
            _ = try await sut.parse(userInfo: userInfo)

            XCTFail("Expected missing conference error to be thrown")
        } catch NotificationParseError.noConferenceFound {

        }
    }
}

extension NotificationParserTests {
    func validPayload(id: String, subscriptionID: String) -> [AnyHashable: Any] {
        [
            "ck": [
                "qry" : [
                    "rid": id,
                    "sid": subscriptionID
                ]
            ]
        ]
    }
}
