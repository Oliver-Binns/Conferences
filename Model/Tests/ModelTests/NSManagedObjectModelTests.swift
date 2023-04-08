@testable import Model
import CoreData
import XCTest

final class NSManagedObjectModelTests: XCTestCase {
    func testModelExists() {
        XCTAssertNotNil(NSManagedObjectModel.conferences)
    }
}
