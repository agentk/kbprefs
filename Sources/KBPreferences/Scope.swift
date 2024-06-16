import Foundation

@_silgen_name("_CFPreferencesCopyApplicationMap")
func _CFPreferencesCopyApplicationMap(_: CFString!, _: CFString!) -> CFDictionary!

public enum Scope: CaseIterable {
    case currentUserCurrentHost
    case anyUserCurrentHost
    case currentUserAnyHost
    case anyUserAnyHost

    public var name: String {
        switch self {
        case .currentUserCurrentHost: return "host"
        case .anyUserCurrentHost: return "sudoHost"
        case .currentUserAnyHost: return "user"
        case .anyUserAnyHost: return "sudo"
        }
    }

    var user: CFString {
        switch self {
        case .currentUserAnyHost,
             .currentUserCurrentHost:
            return kCFPreferencesCurrentUser
        case .anyUserAnyHost, 
             .anyUserCurrentHost:
            return kCFPreferencesAnyUser
        }
    }

    var host: CFString {
        switch self {
        case .currentUserCurrentHost,
             .anyUserCurrentHost:
            return kCFPreferencesCurrentHost
        case .currentUserAnyHost, 
             .anyUserAnyHost:
            return kCFPreferencesAnyHost
        }
    }

    func applicationMap() -> [String: [URL]] {
        _CFPreferencesCopyApplicationMap(user, host) as? [String: [URL]] ?? [:]
    }
}
