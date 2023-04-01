import CoreLocation
import Model
import XCTest
@testable import Notifications

final class NotificationParserTests: XCTestCase {
    var sut: NotificationParser!
    var service: MockDataService!
    var store: MockDataStore!

    override func setUp() {
        super.setUp()

        service = MockDataService()
        store = MockDataStore()

        sut = .init(service: service, store: store)
    }

    override func tearDown() {
        sut = nil
        service = nil
        store = nil
        super.tearDown()
    }

    func testParseEditAttendance() async throws {
        let conferenceID = UUID()
        let conference = Conference.mock()
        service.data = [Attendance(conferenceID: conferenceID), conference]

        let attendance = CDAttendance(context: store.context)
        attendance.conferenceId = conferenceID.uuidString
        try store.insert(object: attendance)

        let userInfo = validPayload(id: "abc", subscriptionID: "editAttendance")
        let (returnedConference, returnedAttendance) = try await sut.parse(userInfo: userInfo)
        XCTAssertEqual(returnedConference.id, conference.id)
        XCTAssertEqual(returnedAttendance, attendance)
    }

    func testParseEditConferenceAllowsNilAttendance() async throws {
        let conference = Conference.mock()
        service.data = [conference]

        let userInfo = validPayload(id: "abc", subscriptionID: "editConference")
        let (returnedConference, attendance) = try await sut.parse(userInfo: userInfo)
        XCTAssertEqual(returnedConference.id, conference.id)
        XCTAssertNil(attendance)
        
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

extension Conference {
    static func mock(id: UUID = UUID(), cfpDates: [Date] = []) -> Conference {
        let startDate = Calendar.current.date(byAdding: .month, value: 2, to: .now)!

        return Conference(id: id,
                          name: "Mock Conference",
                          website: nil, twitter: nil,
                          venue: Venue(name: "Mock Venue",
                                       city: "London", country: "United Kingdom",
                                       location: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                          cfpSubmission: .init(dates: cfpDates),
                          dates: startDate...Date.distantFuture)
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
