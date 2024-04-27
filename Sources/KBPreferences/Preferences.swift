import Foundation

public class Preferences {
    private let applications: [ScopedPreference]
    private let ignoreApplications: [Regex<AnyRegexOutput>]
    private let ignoreKeys: [Regex<AnyRegexOutput>]

    public init(ignoreApplications: [String], ignoreKeys: [String]) throws {
        let ignoreApplicationsRegex = try ignoreApplications.map(Regex.init)
        self.ignoreApplications = ignoreApplicationsRegex
        self.ignoreKeys = try ignoreKeys.map(Regex.init)
        applications = Scope.allCases.flatMap { scope in
            scope.applicationMap()
                .filter { element in
                    ignoreApplicationsRegex.first { element.key.wholeMatch(of: $0) != nil } == nil
                }
                .map { (app, urls) in
                ScopedPreference(application: app, scope: scope, urls: urls)
            }
        }
    }

    public func read(scope: Scope) -> [String: [String: Value]] {
        var result: [String: [String: Value]] = [:]
        for application in applications.filter({ $0.scope == scope }) {
            result[application.application] = application.read()
        }
        return result
    }

    public func read(application: String, scope: Scope) -> [String: Value] {
        guard let application = applications.first(where: { $0.application == application && $0.scope == scope }) else { return [:] }
        return application.read().filter { element in
            ignoreKeys.first { element.key.wholeMatch(of: $0) != nil } == nil
        }
    }

    public var allPreferenceRoots: [URL] {
        var result = [URL]()
        applications.flatMap(\.urls).forEach { url in
            guard !result.contains(url) else { return }
            result.append(url)
        }
        return result.sorted { $0.path() > $1.path() }
    }

    public func write(application: String, values: [String: Value], scope: Scope) {
        guard let application = applications.first(where: { $0.application == application && $0.scope == scope }) else {
            print("Skipping unknown application: \(application) in scope: \(scope)")
            return
        }
        application.write(values)
        print("Imported: \(application.application) \(scope) \(values.count) values")
    }
}

extension [String: Value] {
    public func onlyKeys(_ keys: [String]) -> Self {
        filter { keys.contains($0.key) }
    }
}
