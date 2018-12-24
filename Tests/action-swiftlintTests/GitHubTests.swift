import Foundation
import Lib
import XCTest

let relativePathOfFile = #file.replacingOccurrences(of: projectRootPath, with: "")
typealias Annotation = GitHub.Repository.CheckRun.Annotation

class GitHubTests: XCTestCase {
    let annotation = Annotation(path: relativePathOfFile, start_line: #line, start_column: #column,
                                annotation_level: .failure, message: "testEncodeAnnotation")

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
                  "annotation_level" : "\(annotation.annotation_level)",
                  "end_column" : \(annotation.end_column ?? 0),
                  "end_line" : \(annotation.end_line),
                  "message" : "\(annotation.message)",
                  "path" : "\(annotation.path.replacingOccurrences(of: "/", with: "\\/"))",
                  "start_column" : \(annotation.start_column ?? 0),
                  "start_line" : \(annotation.start_line)
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
