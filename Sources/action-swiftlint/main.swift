import Dispatch
import Foundation
import Lib

DispatchQueue.global().async {
    let (status, violations) = SwiftLint.lint(Array(CommandLine.arguments.dropFirst()))
    defer { exit(status) }
    guard !violations.isEmpty else { return }
    violations.sorted().forEach { print($0) }

    guard let repository = GitHub.repository, let checkRun = repository.currentCheckRun() else { return }
    repository.update(checkRun, with: violations.map(annotation(from:)))
}

dispatchMain()
