import Lib
import XCTest

class SwiftLintTests: XCTestCase {
    func testLint() {
        let (status, violations) = SwiftLint.lint(in: projectRootURL)
        XCTAssertEqual(status, 0)
        XCTAssertEqual(violations.count, 7)
        violations.forEach { violation in
            if violation.severity == .error {
                projectRootURL.appendingPathComponent(violation.file).path.withStaticString { file in
                    XCTFail(violation.reason, file: file, line: UInt(violation.line))
                }
            }
        }
    }
}
