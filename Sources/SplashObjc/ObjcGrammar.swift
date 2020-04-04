import Splash
import Foundation

public struct ObjcGrammar: Grammar {
    public var delimiters: CharacterSet
    public var syntaxRules: [SyntaxRule]

    public init() {
        var delimiters = CharacterSet.alphanumerics.inverted
        delimiters.remove("_")
        delimiters.remove("\"")
        delimiters.remove("#")
        delimiters.remove("*")
        delimiters.remove("@")
        self.delimiters = delimiters

        syntaxRules = [
            PreprocessingRule(),
            StringLiteral(),
            NumberRule(),
            CharacterLiteralRule(),
            TypeRule(),
            PropertyRule(),
            KeywordRule(),
        ]
    }

    static let declarationKeywords: Set<String> = [
        "@interface", "@end", "@implementation", "@property", "@synthesize"
    ]

    static let keywords: Set<String> = [
        "static", "const",

        //Primitive types
        "int", "double", "float", "char", "struct", "void", "BOOL",
        "instancetype", "id", "long", "short", "unsigned",

        //Objc runtime
        "SEL", "IMP", "@selector",

        //---
        "@synchronized",

        //----
        "nonatomic", "atomic", "readwrite", "readonly", "assign", "copy",
        "nullable", "nonnull", "strong", "weak", "unsafe_unretained",

        //---
        "self", "super",

        //Control Flow
        "return", "if", "else", "continue", "switch", "case", "break", "default",
        "@try", "@catch", "do", "while",

        //Values
        "YES", "NO", "nil", "NULL"
    ]

    struct StringLiteral: SyntaxRule {
        var tokenType: TokenType { return .string }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix(#"@""#) &&
               segment.tokens.current.hasSuffix("\"") {
                return true
            }

            return false
        }
    }

    struct KeywordRule: SyntaxRule {
        var tokenType: TokenType { return .keyword }

        func matches(_ segment: Segment) -> Bool {
            return keywords.contains(segment.tokens.current)
                || declarationKeywords.contains(segment.tokens.current)
        }
    }

    struct TypeRule: SyntaxRule {
        var tokenType: TokenType { return .type }

        func matches(_ segment: Segment) -> Bool {
            // Types should not be highlighted when declared
            if let previousToken = segment.tokens.previous {

                //Types after @property should be highlighted as usual
                var filteredDeclarationKeywords = declarationKeywords
                filteredDeclarationKeywords.remove("@property")

                guard !filteredDeclarationKeywords.contains(previousToken) else {
                    return false
                }
            }

            //Capitalized Words at the beginning of strings and capitalized character literals
            //Are not to be considered types.
            guard segment.tokens.previous != "'" && segment.tokens.next != "'" else {
                return false
            }

            guard let firstCharacter = segment.tokens.current.first.map(String.init) else {
                return false
            }

            let isCapitalized = firstCharacter != firstCharacter.lowercased()

            guard isCapitalized else {
                return false
            }

            return true
        }
    }

    struct NumberRule: SyntaxRule {
        var tokenType: TokenType { return .number }

        func matches(_ segment: Segment) -> Bool {
            let tokens = segment.tokens

            if tokens.current.isNumber || tokens.current.isNumberObjectLiteral {
                return true
            }

            //Floating points numbers come in the format number.number
            if tokens.current == ".", let previous = tokens.previous, let next = tokens.next {
                return (previous.isNumber || previous.isNumberObjectLiteral)
                    && (next.isNumber || next.isNumberObjectLiteral)
            }

            //@YES and @NO will be highlighter as numbers
            if tokens.current == "@YES" || tokens.current == "@NO" {
                return true
            }

            return false
        }
    }

    struct CharacterLiteralRule: SyntaxRule {
        //Character literals get highlighted the same way as number literals
        var tokenType: TokenType = .number

        func matches(_ segment: Segment) -> Bool {
            let current = segment.tokens.current
            let next = segment.tokens.next

            //Character object prefix @ must be highlighted same as the actual character
            if current == "@" && next == "'" {
                return true
            }

            //Character delimiter must be highlighted same as the actual character
            if current == "'" {
                return true
            }

            //Character object literal format is @'characterhere'
            return segment.tokens.previous == "'" && segment.tokens.next == "'"
        }
    }

    struct PreprocessingRule: SyntaxRule {
        var tokenType: TokenType { return .preprocessing }

        private let preprocessorDirective: Set<String> = [
            "#define", "#include", "#import", "undef", "ifdef", "ifndef",
            "#if", "#endif", "#elif", "#else",
            "#error", "#pragma"
        ]

        func matches(_ segment: Segment) -> Bool {
            if preprocessorDirective.contains(segment.tokens.current) {
                return true
            }

            //Everything on the preprocessor directive line is highlighted the same way
            for directive in preprocessorDirective {
                if segment.tokens.onSameLine.contains(directive) {
                    return true
                }
            }

            return false
        }
    }

    struct PropertyRule: SyntaxRule {
        var tokenType: TokenType { return .property }

        func matches(_ segment: Segment) -> Bool {
            guard !segment.tokens.onSameLine.isEmpty else {
                return false
            }

            guard let firstCharacter = segment.tokens.current.first, firstCharacter.isLetter else {
                return false
            }

            guard segment.tokens.previous == "." else {
                return false
            }

            return segment.tokens.onSameLine.first != "#import"
        }
    }

    public func isDelimiter(_ delimiterA: Character, mergableWith delimiterB: Character) -> Bool {
        switch (delimiterA, delimiterB) {
        case ("'", ";"):
            //Cannot be merged,
            return false
        default:
            return true
        }
    }
}

extension String {
    var isNumber: Bool {
        if hasSuffix("L")
            || hasSuffix("F")
            || hasSuffix("f")
            || hasSuffix("U") {
            return String(dropLast()).isNumber
        }

        if hasSuffix("LL") {
            return String(dropLast(2)).isNumber
        }

        let validAsInt = Int(self) != nil
        return validAsInt
    }

    var isNumberObjectLiteral: Bool {
        guard hasPrefix("@") else { return false }
        let withoutAtSign = dropFirst()
        return String(withoutAtSign).isNumber
    }

    var isCharacterObjectLiteral: Bool {
        guard hasPrefix("@") else { return false }
        let withoutAtSign = String(dropFirst())

        return withoutAtSign.hasPrefix("'")
            && withoutAtSign.hasSuffix("'")
            && withoutAtSign.count > 2
    }
}
