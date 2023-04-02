import XCTest

extension XCTestCase {
    func expectation(for outcome: @autoclosure @escaping () -> Bool) -> XCTestExpectation {
        expectation(for: .init { _, _ in
            outcome()
        }, evaluatedWith: nil)
    }

    func wait(for outcome: @autoclosure @escaping () -> Bool, timeout: TimeInterval) {
        let exp = expectation(for: outcome())
        wait(for: [exp], timeout: 3)
    }
}
