import Foundation
import Lib
import XCTest

class GitHubTests: XCTestCase {
    let annotation = GitHub.Repository.CheckRun.Annotation(path: "Tests/action-swiftlintTests/SwiftLintTests.swift",
                                                           start_line: 19,
                                                           annotation_level: .failure,
                                                           message: "testEncodeAnnotation")

    func testEncodeAnnotation() {
        let encoder = JSONEncoder()
        var outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
        if #available(macOS 10.13, *) {
            outputFormatting = [outputFormatting, .sortedKeys]
        }
        #if canImport(Glibc)
        outputFormatting = [outputFormatting, .sortedKeys]
        #endif
        encoder.outputFormatting = outputFormatting
        do {
            let data = try encoder.encode(annotation)
            let jsonString = String(data: data, encoding: .utf8)
            XCTAssertEqual(jsonString, """
                {
                  "annotation_level" : "failure",
                  "end_line" : 19,
                  "message" : "testEncodeAnnotation",
                  "path" : "\(annotation.path.replacingOccurrences(of: "/", with: "\\/"))",
                  "start_line" : 19
                }
                """)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCheckRuns() {
        guard let repository = GitHub.repository else {
            print("Skipping \(#function) because it seems not to be in the GitHub Actions environment.")
            return
        }
        guard let checkRun = repository.currentCheckRun() else {
            XCTFail("`currentCheckRun()` failed")
            return
        }
        XCTAssertTrue(repository.update(checkRun, with: [annotation]))
    }
}
