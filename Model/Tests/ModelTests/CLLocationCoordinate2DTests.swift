import CoreLocation
import XCTest
@testable import Model

final class CLLocationCoordinate2DTests: XCTestCase {
    func testEncoding() throws {
        let sut = CLLocationCoordinate2D(latitude: 2, longitude: 3)

        let data = try JSONEncoder().encode(sut)
        let json = String(data: data, encoding: .utf8)

        XCTAssertEqual(json, "[2,3]")
    }

    func testDecoding() throws {
        let sut = try XCTUnwrap("[5.013423, 3.123425]".data(using: .utf8))

        let coordinate = try JSONDecoder()
            .decode(CLLocationCoordinate2D.self, from: sut)

        XCTAssertEqual(coordinate.latitude, 5.013423)
        XCTAssertEqual(coordinate.longitude, 3.123425)
    }
}
