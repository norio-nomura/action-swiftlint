import XCTest
@testable import errors

final class errorsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(errors().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
