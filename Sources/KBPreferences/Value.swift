import Foundation

public enum ValueError: Error {
    case missingValue
}

public enum Value: Equatable {
    case string(String)
    case data(Data)
    case int(Int)
    case float(Decimal)
    case bool(Bool)
    case date(Date)
    case array([Value])
    case dict([String: Value])

    init(any: Any) {
        let cfType = CFGetTypeID(any as CFTypeRef)
        let typeDescription = CFCopyTypeIDDescription(cfType)

        switch (cfType, any) {
        case let (CFBooleanGetTypeID(), any as Bool):
            self = .bool(any)
        case let (CFDataGetTypeID(), any as Data):
            self = .data(any)
        case let (CFDateGetTypeID(), any as Date):
            self = .date(any)
        case let (CFNumberGetTypeID(), any as Int):
            self = .int(any)
        case let (CFNumberGetTypeID(), any as NSNumber):
            self = .float(any.decimalValue)
        case let (CFStringGetTypeID(), any as String):
            self = .string(any)
        case let (CFArrayGetTypeID(), any as [Any]):
            self = .array(any.map({ Value(any: $0) }))
        case let (CFDictionaryGetTypeID(), any as [String: Any]):
            self = .dict(any.mapValues({ Value(any: $0) }))
        default:
            print("Unknown combo: \(String(describing: typeDescription!)) :: \(any)")
            self = .string(String(describing: any))
        }
    }

    var asCFValue: CFPropertyList {
        switch self {
        case let .string(value): return value as CFString
        case let .data(value): return value as CFData
        case let .int(value): return value as CFNumber
        case let .float(value): return value as CFNumber
        case let .bool(value): return value as CFBoolean
        case let .date(value): return value as CFDate
        case let .array(value): return value.map(\.asCFValue) as CFArray
        case let .dict(value): return value.mapValues(\.asCFValue) as CFDictionary
        }
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .string(value): return "\"\(value)\""
        case let .data(value):
            if let value = String(data: value, encoding: .utf8) {
                return "Data(\"\(value)\""
            }
            let hex = value.hexEncodedString()
            if hex.count > 64 {
                return "Data(\(hex.prefix(32)) ... \(hex.suffix(32)))"
            }
            return "Data(\(hex))"
        case let .int(value): return "\(value)"
        case let .float(value): return "\(value)"
        case let .bool(value): return "\(value)"
        case let .date(value): return "Date(\(value))"
        case let .array(value): return "\(value)"
        case let .dict(value): return "\(value)"
        }
    }
}

extension Value: Codable {
    enum CodingKeys: String, CodingKey {
        case string
        case data
        case int
        case float
        case bool
        case date
        case array
        case dict
    }

    public init (from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let any = try? decoder.container(keyedBy: CodingKeys.self).decode(Int.self, forKey: .int) {
            self = .int(any)
            return
        }

        if let any = try? decoder.container(keyedBy: CodingKeys.self).decode(Decimal.self, forKey: .float) {
            self = .float(any)
            return
        }

        if let any = try? decoder.container(keyedBy: CodingKeys.self).decode(Bool.self, forKey: .bool) {
            self = .bool(any)
            return
        }

        if let any = try? decoder.container(keyedBy: CodingKeys.self).decode(Date.self, forKey: .date) {
            self = .date(any)
            return
        }

        if let any = try? decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .data) {
            self = .data(Data(base64Encoded: Data(any.utf8))!)
            return
        }

        if let any = try? container.decode(String.self) {
            self = .string(any)
            return
        }

        if let any = try? container.decode([Value].self) {
            self = .array(any)
            return
        }

        if let any = try? container.decode([String: Value].self) {
            self = .dict(any)
            return
        }

        try print(decoder.singleValueContainer())
        throw ValueError.missingValue
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .string(any):
            var container = encoder.singleValueContainer()
            try container.encode(any)

        case let .data(any):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(any.base64EncodedString(), forKey: .data)

        case let .int(any):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(any, forKey: .int)

        case let .float(any):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(any, forKey: .float)

        case let .bool(any):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(any, forKey: .bool)

        case let .date(any):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(any, forKey: .date)

        case let .array(any):
            var container = encoder.singleValueContainer()
            try container.encode(any)

        case let .dict(any):
            var container = encoder.singleValueContainer()
            try container.encode(any)
        }
    }
}
