import Dispatch
import Foundation

public enum GitHub {
    public static let baseURL = URL(string: "https://api.github.com")!

    public struct Repository {
        let repo: String
        let token: String?
        public init(_ repo: String, token: String? = nil) {
            self.repo = repo
            self.token = token
        }
    }
}

extension GitHub {
    public static var repository: GitHub.Repository? {
        guard let token = environment("GITHUB_TOKEN") else { return nil }
        guard let repo = environment("GITHUB_REPOSITORY") else { return nil }
        return GitHub.Repository(repo, token: token)
    }
}

extension GitHub.Repository {
    public struct CheckRun: Decodable {
        public var id: Int
        public var name: String
        public var url: URL
        public var output: Output?
        public var app: App
        public var check_suite: CheckSuite
    }
}

extension GitHub.Repository.CheckRun {
    public struct Output: Decodable {
        public var title: String?
        public var summary: String?
        public var text: String?
        public var annotations: [Annotation]?
    }

    public struct Annotation: Codable {
        public enum Level: String, Codable {
            case notice, warning, failure
        }
        public var path: String
        public var start_line: Int
        public var end_line: Int
        public var start_column: Int?
        public var end_column: Int?
        public var annotation_level: Level
        public var message: String
        public var title: String?
        public var raw_details: String?

        public init(path: String,
                    start_line: Int,
                    end_line: Int? = nil,
                    start_column: Int? = nil,
                    end_column: Int? = nil,
                    annotation_level: Level,
                    message: String,
                    title: String? = nil,
                    raw_details: String? = nil) {
            self.path = path
            self.start_line = start_line
            self.end_line = end_line ?? start_line
            self.start_column = self.start_line == self.end_line ? start_column : nil
            self.end_column = self.start_line == self.end_line ? end_column ?? start_column : nil
            self.annotation_level = annotation_level
            self.message = message
            self.title = title
            self.raw_details = raw_details
        }
    }

    public struct App: Decodable {
        public var id: Int
        public var name: String
    }

    public struct CheckSuite: Decodable {
        public var id: Int
    }
}

extension GitHub.Repository {
    public func currentCheckRun() -> CheckRun? {
        guard let sha = environment("GITHUB_SHA") else { return nil }
        guard let name = environment("GITHUB_ACTION") else { return nil }
        guard let checkRun = findCheckRun(for: sha, with: name) else {
            print("Current Action `\(name)` not found!")
            return nil
        }
        return checkRun
    }

    public func findCheckRun(for ref: String, with name: String) -> CheckRun? {
        return checkRuns(for: ref).first { checkRun -> Bool in
            checkRun.name == name && checkRun.app.name == "GitHub Actions"
        }
    }

    public func checkRuns(for ref: String) -> [CheckRun] {
        struct Response: Decodable {
            var check_runs: [CheckRun]
        }

        let response1: Response? = request(url(with: "/repos/\(repo)/commits/\(ref)/check-runs"))
        guard let suite_id = response1?.check_runs.first?.check_suite.id else { return [] }
        let response2: Response? = request(url(with: "/repos/\(repo)/check-suites/\(suite_id)/check-runs"))
        return response2?.check_runs ?? []
    }

    @discardableResult
    public func update(_ checkRun: CheckRun, with annotations: [CheckRun.Annotation]) -> Bool {
        struct Request: Encodable {
            struct Output: Encodable {
                var title: String?
                var summary: String?
                var annotations: [CheckRun.Annotation]
            }
            var output: Output
        }

        guard let output = checkRun.output else {
            print("\(checkRun) has no output.")
            return false
        }
        let batchSize = 50
        var rest = ArraySlice(annotations)
        while !rest.isEmpty {
            let annotations = Array(rest.prefix(batchSize))
            rest = rest.dropFirst(batchSize)
            let output = Request.Output(title: output.title, summary: output.summary, annotations: annotations)
            let response: CheckRun? = request(checkRun.url, method: "PATCH", with: Request(output: output))
            if response == nil {
                return false
            }
        }
        return true
    }

    // MARK: - private

    private func url(with path: String) -> URL {
        return GitHub.baseURL.appendingPathComponent(path)
    }

    private func request<T: Decodable, U: Encodable>(_ url: URL, method: String? = "GET", with encodable: U? = nil) -> T? {
        do {
            return request(url, method: method, with: try JSONEncoder().encode(encodable))
        } catch {
            print(error)
            return nil
        }
    }

    private func request<T>(_ url: URL, method: String? = "GET", with data: Data? = nil) -> T? where T: Decodable {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = token {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/vnd.github.antiope-preview+json", forHTTPHeaderField: "Accept")
        request.httpBody = data

        let semaphore = DispatchSemaphore(value: 0)
        var result: T?
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer { semaphore.signal() }
            if let error = error {
                print(error)
                return
            }
            guard let httpURLResponse = response as? HTTPURLResponse else {
                print("Unknown response: \(String(describing: response))")
                return
            }
            guard (200...299).contains(httpURLResponse.statusCode) else {
                print("server error status: \(httpURLResponse.statusCode)")
                return
            }
            guard let data = data else {
                print("server returns no data")
                return
            }
            do {
                result = try JSONDecoder().decode(T.self, from: data)
            } catch {
                print(error)
            }
        }

        task.resume()
        semaphore.wait()

        return result
    }
}

private func environment(_ key: String) -> String? {
    guard let value = ProcessInfo.processInfo.environment[key] else {
        print("Can not find `\(key)` environment variable.")
        return nil
    }
    return value
}
