import Dispatch
import Foundation

public enum SwiftLint {
    public struct Violation: Decodable, CustomStringConvertible, Comparable {
        public enum Severity: String, Decodable, CustomStringConvertible {
            case warning
            case error

            public init?(rawValue: String) {
                switch rawValue.lowercased() {
                case "warning": self = .warning
                case "error": self = .error
                default: return nil
                }
            }
            public var description: String { return rawValue }
        }

        public var character: Int?
        public var file: String
        public var line: Int
        public var reason: String
        public var rule_id: String
        public var severity: Severity
        public var type: String

        public var description: String {
            return "\(file):\(line):\(character ?? 1): \(severity.rawValue): \(type) Violation: \(reason) (\(rule_id))"
        }

        public static func < (lhs: Violation, rhs: Violation) -> Bool {
            guard lhs.file == rhs.file else { return lhs.file < rhs.file }
            guard lhs.line == rhs.line else { return lhs.line < rhs.line }
            let lhsCharacter = lhs.character ?? 1
            let rhsCharacter = rhs.character ?? 1
            guard lhsCharacter == rhsCharacter else { return lhsCharacter < rhsCharacter }
            guard lhs.rule_id == rhs.rule_id else { return lhs.rule_id < rhs.rule_id }
            return false
        }
    }

    public static func lint(_ args: [String] = [], in directoryURL: URL? = nil) -> (status: Int32, violations: [Violation]) {
        let currentDirectoryURL = directoryURL ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let arguments = ["swiftlint", "lint", "--reporter", "json"] + args
        let result = execute(arguments, in: currentDirectoryURL)
        if let stderrString = result.stderr.flatMap({ String(data: $0, encoding: .utf8) }) {
            fputs(stderrString, stderr)
            fflush(stderr)
        }
        return (result.status, result.stdout.map {
            do {
                let currentDirectory = currentDirectoryURL.appendingPathComponent("/").path
                return try JSONDecoder().decode([Violation].self, from: $0).map {
                    var violation = $0
                    violation.file = violation.file.replacingOccurrences(of: currentDirectory, with: "")
                    return violation
                }
            } catch {
                print(error)
                return []
            }
        } ?? [])
    }
}
