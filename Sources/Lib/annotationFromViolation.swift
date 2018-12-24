import Foundation

public func annotation(from violation: SwiftLint.Violation) -> GitHub.Repository.CheckRun.Annotation {
    return GitHub.Repository.CheckRun.Annotation(path: violation.file,
        start_line: violation.line,
        start_column: violation.character,
        annotation_level: annotationLevel(from: violation.severity),
        message: violation.reason,
        title: violation.type,
        raw_details: nil)
}

public func annotationLevel(from serverity: SwiftLint.Violation.Severity) -> GitHub.Repository.CheckRun.Annotation.Level {
    switch serverity {
    case .error: return .failure
    case .warning: return .warning
    }
}
