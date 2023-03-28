@testable import Conferences
import CoreData
import XCTest

final class NSManagedObjerctModelTests: XCTestCase {
    func testModelExists() {
        XCTAssertNotNil(NSManagedObjectModel.conferences)
    }
}
