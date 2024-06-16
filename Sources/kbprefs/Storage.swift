import Foundation
import KBPreferences

typealias PreferenceSequence = [String: [String: Value]]

struct Storage: Codable {
    struct Watch: Codable {
        var ignoreApplications: [String] = []
        var ignoreKeys: [String] = []
    }
    var user: PreferenceSequence = [:]
    var host: PreferenceSequence = [:]
    var sudo: PreferenceSequence = [:]
    var sudoHost: PreferenceSequence = [:]
    var watch: Watch = Watch()
}
