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
        delimiters.remove("@")
        delimiters.remove("%")
        self.delimiters = delimiters

        syntaxRules = [
            PreprocessingRule(),
            CommentRule(),
            StringLiteral(),
            NumberRule(),
            CharacterLiteralRule(),
            TypeRule(),
            CallRule(),
            PropertyRule(),
            KeywordRule()
        ]
    }

    static let declarationKeywords: Set<String> = [
        "@interface", "@end", "@implementation", "@property", "@synthesize"
    ]

    static let keywords: Set<String> = [
        "static", "const",

        //Types
        "int", "double", "float", "char", "struct", "void", "BOOL",
        "instancetype", "id", "long", "short", "unsigned", "typedef",
        "enum",

        //Objc runtime
        "SEL", "IMP", "@selector",

        //---
        "@synchronized",

        //Property Attributes
        "nonatomic", "atomic", "readwrite", "readonly", "getter",
        "assign", "copy", "strong", "weak", "unsafe_unretained",
        "_Nonnull", "_Nullable", "nullable", "nonnull", "__block",

        //---
        "self", "super",

        //Control Flow
        "return", "if", "else", "continue", "switch", "case", "break", "default",
        "@try", "@catch", "do", "while", "for",

        //Values
        "YES", "NO", "nil", "NULL"
    ]

    struct StringLiteral: SyntaxRule {
        var tokenType: TokenType { return .string }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix("@\"") &&
               segment.tokens.current.hasSuffix("\"") {
                return true
            }

            guard segment.isWithinStringLiteral(withStart: "@\"", end: "\"") else {
                return false
            }

            return true
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
            /*Prevent enum values from being highlighted as a Type in enum definitions like the following:
             typedef enum {
                 UITableViewCellStyleDefault,
                 UITableViewCellStyleValue1,
                 UITableViewCellStyleValue2,
                 UITableViewCellStyleSubtitle
             } UITableViewCellStyle;
            */
            if let lastOpeningBracketIndex = segment.tokens.all.lastIndex(of: "{") {
                let isWithinBrackets = segment.tokens.count(of: "{") != segment.tokens.count(of: "}")
                let beforeLastOpeningBracket = segment.tokens.all.index(lastOpeningBracketIndex, offsetBy: -1)

                if segment.tokens.all[beforeLastOpeningBracket] == "enum" {
                    //Highlight enum cases as plain text
                    if isWithinBrackets {
                        return false
                    }

                    //Highlight the typedef name as plain text
                    if segment.tokens.previous == "}" && segment.tokens.next == ";" {
                        return false
                    }
                }
            }

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

    struct CallRule: SyntaxRule {
        var tokenType: TokenType { return .call }

        func matches(_ segment: Segment) -> Bool {
            guard !segment.tokens.onSameLine.isEmpty else {
                return false
            }

            guard let previous = segment.tokens.previous,
                //Prevent function arguments from being treated as function call
                previous != ":",

                //In @interface Person: NSObject, Person should not be considered a call
                !declarationKeywords.contains(previous) else {
                return false
            }

            guard segment.tokens.next == "]" || segment.tokens.next == ":" else {
                return false
            }

            guard let firstCharacter = segment.tokens.current.first, firstCharacter.isLetter else {
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

    struct CommentRule: SyntaxRule {
        var tokenType: TokenType { return .comment }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix("/*") {
                if segment.tokens.current.hasSuffix("*/") {
                    return true
                }
            }

            if segment.tokens.current.hasPrefix("//") {
                return true
            }

            for singleLineCommentToken in ["//", "///"] {
                if segment.tokens.onSameLine.contains(singleLineCommentToken) {
                    return true
                }
            }

            if ["/*", "/**", "*/"].contains(segment.tokens.current) {
                return true
            }

            let multiLineStartCount = segment.tokens.count(of: "/*") + segment.tokens.count(of: "/**")
            return multiLineStartCount != segment.tokens.count(of: "*/")
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
            return false
        case ("]", ";"):
            //Prevent function calls at the end of a line from being merged with semicolon
            return false
        case (":", "["):
            //Prevents : and [ from being merged in [NSMutableArray arrayWithArray:[arrayOfArrays firstObject]]
            //Thus allowing result of function call to be used as a function parameter.
            return false
        case (";", "/"):
            //Prevents comments right after punctuation to be merged with the punctuation.
            //In the following line of code, ;// would be merged together as plainText otherwise
            //int n = 5;// number
            return false
        case ("]", ")"):
            //Prevents ] and ) from merging in the following line,
            //to allow return value of a call to be used in a boolean check
            //if ([self call]) {}
            return false
        case (_, ":"):
            //Prevent any delimiter from merging with :
            //Example: case 'a':
            return false
        case (":", "^"):
            //Prevents : and ^ from being merged when passing a block as a method argument
            //[someObject someMethodThatTakesABlock:^ReturnType (parameters) {...}];
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

extension Segment {
    func isWithinStringLiteral(withStart start: String, end: String) -> Bool {
        if tokens.current.hasPrefix(start) {
            return true
        }

        if tokens.current.hasSuffix(end) {
            return true
        }

        var markerCounts = (start: 0, end: 0)

        for token in tokens.onSameLine {
            if token == start {
                if start != end || markerCounts.start == markerCounts.end {
                    markerCounts.start += 1
                } else {
                    markerCounts.end += 1
                }
            } else if token == end && start != end {
                markerCounts.end += 1
            } else {
                if token.hasPrefix(start) {
                    markerCounts.start += 1
                }

                if token.hasSuffix(end) {
                    markerCounts.end += 1
                }
            }
        }

        return markerCounts.start != markerCounts.end
    }
}
