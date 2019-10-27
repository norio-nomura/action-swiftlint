import Lib
import XCTest
import class Foundation.Bundle

final class action_swiftlintTests: XCTestCase {
    func test_action_swiftlint() throws {
        let fooBinary = productsDirectory.appendingPathComponent("action-swiftlint")
        let result = Lib.execute([fooBinary.path], in: projectRootURL)
        let output = result.stdout.flatMap { String(data: $0, encoding: .utf8) }

        let warningMessage = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] == nil ?
            "Can not find `GITHUB_TOKEN` environment variable.\n" : ""

        XCTAssertEqual(output, """
Sources/Lib/GitHub.swift:48:16: warning: Nesting Violation: Types should be nested at most 1 level deep (nesting)
Sources/Lib/GitHub.swift:143:9: warning: Nesting Violation: Types should be nested at most 1 level deep (nesting)
Sources/Lib/GitHub.swift:155:9: warning: Nesting Violation: Types should be nested at most 1 level deep (nesting)
Sources/Lib/GitHub.swift:156:13: warning: Nesting Violation: Types should be nested at most 1 level deep (nesting)
Sources/Lib/GitHub.swift:156:13: warning: Nesting Violation: Types should be nested at most 1 level deep (nesting)
Sources/Lib/SwiftLint.swift:6:16: warning: Nesting Violation: Types should be nested at most 1 level deep (nesting)
Sources/Lib/execute().swift:4:68: warning: Large Tuple Violation: Tuples should have at most 2 members. (large_tuple)
\(warningMessage)
""")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
