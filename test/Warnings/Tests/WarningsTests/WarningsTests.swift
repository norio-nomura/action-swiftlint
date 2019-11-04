import XCTest
@testable import Warnings

final class WarningsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Warnings().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
