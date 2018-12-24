import Dispatch
import Foundation

public func execute(_ args: [String], in directory: URL? = nil) -> (status: Int32, stdout: Data?, stderr: Data?) {
    // swiftlint:disable:previous function_body_length
    let process = Process()
    if #available(macOS 10.13, *) {
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        if let directory = directory {
            process.currentDirectoryURL = directory
        }
    } else {
        process.launchPath = "/usr/bin/env"
        if let directory = directory {
            process.currentDirectoryPath = directory.path
        }
    }
    process.arguments = args
#if os(macOS)
    // Xcode's child processes does not have `/usr/local/bin` in `PATH` environment variable.
    var environment = ProcessInfo.processInfo.environment
    if let paths = environment["PATH"].map({ $0.split(separator: ":") }), !paths.contains("/usr/local/bin") {
        environment["PATH"] = (paths + ["/usr/local/bin"]).joined(separator: ":")
        process.environment = environment
    }
#endif
    let stdoutPipe = Pipe(), stderrPipe = Pipe()
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe
    let group = DispatchGroup(), queue = DispatchQueue.global()
    var stdoutData: Data?, stderrData: Data?
    do {
    #if canImport(Darwin)
        if #available(macOS 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
    #elseif compiler(>=5)
        try process.run()
    #else
        process.launch()
    #endif
    } catch let nserror as NSError {
        print(nserror)
        return (Int32(truncatingIfNeeded: nserror.code), nil, nil)
    } catch {
        print(error)
        return (-1, nil, nil)
    }
    queue.async(group: group) { stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile() }
    queue.async(group: group) { stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile() }
    process.waitUntilExit()
    group.wait()
    return (process.terminationStatus, stdoutData, stderrData)
}
