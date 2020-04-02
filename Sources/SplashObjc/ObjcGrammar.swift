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
            StringLiteral(),
            TypeRule(),
            KeywordRule()
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
}
