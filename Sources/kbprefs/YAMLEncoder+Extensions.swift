import Foundation
import Yams

extension YAMLEncoder {
    static let sorted: YAMLEncoder = {
        let encoder = YAMLEncoder()
        encoder.options = .init(sortKeys: true)
        return encoder
    }()
}
