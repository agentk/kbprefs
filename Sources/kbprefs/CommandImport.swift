import Foundation
import KBPreferences
import Yams

struct CommandImport {
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

        func write(dictionary: PreferenceSequence, scope: Scope) {
            for (application, values) in dictionary {
                preferences.write(application: application, values: values, scope: scope)
            }
        }

        write(dictionary: storage.host, scope: .currentUserCurrentHost)
        write(dictionary: storage.sudo, scope: .anyUserCurrentHost)
        write(dictionary: storage.user, scope: .currentUserAnyHost)
    }
}
