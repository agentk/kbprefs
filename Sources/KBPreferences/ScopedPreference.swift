import Foundation

struct ScopedPreference {
    let application: String
    let scope: Scope
    let urls: [URL]

    init(application: String, scope: Scope, urls: [URL]) {
        self.application = application
        self.scope = scope
        self.urls = urls
    }

    func read() -> [String: Value] {
        var result: [String: Value] = [:]
        for url in urls {
            let values = read(url: url)
            result = result.merging(values, uniquingKeysWith: { l, _ in l })
        }
        return result
    }

    func write(_ values: [String: Value]) {
        guard let url = urls.first else { fatalError("Invalid empty URLs list for \(self)") }
        let applicationID = url.appending(path: application).path() as CFString
        CFPreferencesSetMultiple(
            values.mapValues(\.asCFValue) as CFDictionary, //_ keysToSet: CFPropertyList?,
            nil, // _ keysToRemove: CFArray?,
            applicationID, // _ applicationID: CFString,
            scope.user, // _ userName: CFString,
            scope.host // _ hostName: CFString
        )
        CFPreferencesSynchronize(
            applicationID, // _ applicationID: CFString,
            scope.user, // _ userName: CFString,
            scope.host // _ hostName: CFString
        )
    }

    private func read(url: URL) -> [String: Value] {
        let keys = readKeys(url: url)
        let values = readValues(keys: keys, url: url)
        return values
    }

    private func readKeys(url: URL) -> [String] {
        CFPreferencesCopyKeyList(
            url.appending(path: application).path() as CFString,
            scope.user,
            scope.host
        ) as? [String] ?? []
    }

    private func readValues(keys: [String], url: URL) -> [String: Value] {
        let values = CFPreferencesCopyMultiple(
            keys as CFArray,
            url.appending(path: application).path() as CFString,
            scope.user,
            scope.host
        ) as? [String: Any]
        return values?.mapValues({ Value(any: $0) }) ?? [:]
    }
}
