import XCTest

extension GitHubTests {
    static let __allTests = [
        ("testCheckRuns", testCheckRuns),
        ("testEncodeAnnotation", testEncodeAnnotation),
    ]
}

extension SwiftLintTests {
    static let __allTests = [
        ("testLint", testLint),
    ]
}

extension action_swiftlintTests {
    static let __allTests = [
        ("test_action_swiftlint", test_action_swiftlint),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GitHubTests.__allTests),
        testCase(SwiftLintTests.__allTests),
        testCase(action_swiftlintTests.__allTests),
    ]
}
#endif
