import Foundation
import ArgumentParser
import KBPreferences

@main
struct KBPrefs: ParsableCommand {
    enum KBCommand: String, ExpressibleByArgument {
        case `import`
        case export
        case watch

        init?(argument: String) {
            guard let command = KBCommand(rawValue: argument) else { return nil }
            self = command
        }
    }

    @Argument(help: """
        <import|export|watch>.
        - import: Import values on disk into UserDefaults
        - export: Export values in UserDefaults to disk
        - watch: Snapshot current values and watch for changes
        """)
    var command: KBCommand

    @Option(name: .shortAndLong, help: "Path to yaml preference files.")
    var path = "~/.config/preferences/preferences.yaml"

    mutating func run() throws {
        let path = URL(filePath: (self.path as NSString).expandingTildeInPath).standardizedFileURL

        switch command {
        case .import:
            try CommandImport(path: path).run()

        case .export:
            try CommandExport(path: path).run()

        case .watch:
            Task {
                try await CommandWatch(path: path).run()
            }
        }
    }
}
