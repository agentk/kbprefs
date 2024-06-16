import AppKit
import FileWatcher
import Foundation
import KBPreferences
import Yams

struct CommandWatch {
    let decoder = YAMLDecoder()
    let encoder = YAMLEncoder.sorted
    let fileManager = FileManager.default
    let path: URL
    let storage: Storage

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

    @MainActor func run() throws {
        var storage = self.storage

        // Calculate list of all apps to watch
        let preferences = try Preferences(
            ignoreApplications: storage.watch.ignoreApplications,
            ignoreKeys: storage.watch.ignoreKeys
        )

        // Initialise each applications preferences cache
        var cache: [Scope: [String: [String: Value]]] = [
            // host
            .currentUserCurrentHost: preferences.read(scope: .currentUserCurrentHost),
            // sudoHost
            .anyUserCurrentHost: preferences.read(scope: .anyUserCurrentHost),
            // sudo
            .anyUserAnyHost: preferences.read(scope: .anyUserAnyHost),
            // user
            .currentUserAnyHost: preferences.read(scope: .currentUserAnyHost),
        ]

        func dumpChanges() {
            var storageChanged = false

            for (scope, scopeValues) in cache {
                for (application, keyValues) in scopeValues {
                    let newPreferences = preferences.read(application: application, scope: scope)
                    for (key, value) in newPreferences {
                        guard value != keyValues[key] else { continue }
                        print("[\(scope.name)(.\(scope))][\(application)][\(key)] = \(value)")
                        cache[scope]?[application]?[key] = value

                        switch scope {
                        case .currentUserCurrentHost:
                            storage.host[application] = storage.host[application] ?? [:]
                            storage.host[application]![key] = value
                        case .anyUserCurrentHost:
                            storage.sudoHost[application] = storage.sudoHost[application] ?? [:]
                            storage.sudoHost[application]![key] = value
                        case .currentUserAnyHost:
                            storage.user[application] = storage.user[application] ?? [:]
                            storage.user[application]![key] = value
                        case .anyUserAnyHost:
                            storage.sudo[application] = storage.sudo[application] ?? [:]
                            storage.sudo[application]![key] = value
                        }

                        storageChanged = true
                    }
                }
            }

            if storageChanged {
                do {
                    let string = try encoder.encode(storage).inlineYamlValues()
                    try Data(string.utf8).write(to: path)
                } catch {
                    print(error)
                }
            }
        }

        //// Watch the folders of all application preferences
        let watcher = FileWatcher(preferences.allPreferenceRoots.map(\.path))
        var nextSyncTime = Date.now + 1

        watcher.callback = { event in
            // If one of those folders reports a change
            // Reread all prefs and print a list of changes
            // Then write the changed prefs to the yaml file
            print("Trigger: \(URL(filePath: event.path).deletingPathExtension().lastPathComponent)")
            if Date.now > nextSyncTime {
                print("Sync")
                dumpChanges()
                nextSyncTime = Date.now + 1
            }
        }
        
        // Start the main loop consuming 100% CPU
        print("==== Monitoring for CFPreferences changes ====")
        watcher.start()
        NSApplication.shared.run()
    }
}

extension Scope {
    var keyPath: KeyPath<Storage, PreferenceSequence> {
        switch self {
        case .currentUserCurrentHost:
            return \.host
        case .anyUserCurrentHost:
            return \.host
        case .currentUserAnyHost:
            return \.user
        case .anyUserAnyHost:
            return \.sudo
        }
    }
}
