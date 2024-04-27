import Foundation
import KBPreferences
import Yams

struct CommandExport {
    let decoder = YAMLDecoder()
    let encoder = YAMLEncoder.sorted
    let fileManager = FileManager.default
    let path: URL
    var storage: Storage

    init(
        path: URL
    ) throws {
        self.path = path.standardizedFileURL
        if fileManager.fileExists(atPath: path.path()) {
            storage = try decoder.decode(Storage.self, from: Data(contentsOf: path))
        } else {
            storage = Storage()
        }
    }

    func run() throws {
        let preferences = try Preferences(
            ignoreApplications: storage.watch.ignoreApplications,
            ignoreKeys: storage.watch.ignoreKeys
        )

        func refresh(dictionary: inout PreferenceSequence, scope: Scope) {
            for (application, values) in dictionary {
                dictionary[application] = preferences
                    .read(application: application, scope: scope)
                    .onlyKeys(values.keys.map { $0 })
            }
        }

        var storage = storage
        refresh(dictionary: &storage.host, scope: .currentUserCurrentHost)
        refresh(dictionary: &storage.sudo, scope: .anyUserCurrentHost)
        refresh(dictionary: &storage.user, scope: .currentUserAnyHost)

        let string = try encoder.encode(storage).inlineYamlValues()
        try Data(string.utf8).write(to: path)
        print("Exported applications: (host: \(storage.host.count), sudo: \(storage.sudo.count), user: \(storage.user.count))")
        print("Path: \(path.path())")
    }
}
