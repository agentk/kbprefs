import Foundation
import RegexBuilder

extension String {
    func inlineYamlValues(prefix: String = "    ") -> String {
        // let inlineRegex = /\n  (\S.+:)\n    (\S+: \S+)\n  (([:alnum:]|_))/
        func inlineRegex(prefix: String, suffix: String) -> Regex<Regex<(Substring, Regex<Substring>.RegexOutput, Regex<Substring>.RegexOutput, Regex<ChoiceOf<Substring>.RegexOutput>.RegexOutput)>.RegexOutput> {
            Regex {
                One(.newlineSequence)
                prefix
                Capture {
                    One(.whitespace.inverted)
                    OneOrMore(.anyNonNewline)
                    ":"
                }
                One(.newlineSequence)
                "\(prefix)  "
                Capture {
                    OneOrMore(.whitespace.inverted)
                    ": "
                    OneOrMore(.whitespace.inverted)
                }
                One(.newlineSequence)
                suffix
                Capture {
                    ChoiceOf {
                        One(.whitespace.inverted)
                        "_"
                    }
                }
            }
        }

        // /\n  (\S.+:)\n    (\S+: \S+)\n$/
        let endRegex = Regex {
            One(.newlineSequence)
            prefix
            Capture {
                One(.whitespace.inverted)
                OneOrMore(.anyNonNewline)
                ":"
            }
            One(.newlineSequence)
            "\(prefix)  "
            Capture {
                OneOrMore(.whitespace.inverted)
                ": "
                OneOrMore(.whitespace.inverted)
            }
            One(.newlineSequence)
            Anchor.endOfLine
        }

        return self
            .replacing(inlineRegex(prefix: prefix, suffix: "    "), with: { match in "\n\(prefix)\(match.output.1) { \(match.output.2) }\n\(prefix)\(match.output.3)" })
            .replacing(inlineRegex(prefix: prefix, suffix: "    "), with: { match in "\n\(prefix)\(match.output.1) { \(match.output.2) }\n\(prefix)\(match.output.3)" })
            .replacing(inlineRegex(prefix: prefix, suffix: "  "), with: { match in "\n\(prefix)\(match.output.1) { \(match.output.2) }\n  \(match.output.3)" })
            .replacing(inlineRegex(prefix: prefix, suffix: ""), with: { match in "\n\(prefix)\(match.output.1) { \(match.output.2) }\n\(match.output.3)" })
            .replacing(endRegex, with: { match in "\n\(prefix)\(match.output.1) { \(match.output.2) }\n" })
    }
}
