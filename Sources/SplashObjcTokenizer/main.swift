import Foundation
import Splash
import SplashObjc

guard CommandLine.arguments.count > 1 else {
    print("⚠️  Please supply the code to tokenize as a string argument")
    exit(1)
}

let code = CommandLine.arguments[1]
let highlighter = SyntaxHighlighter(format: TokenizerOutputFormat(), grammar: ObjcGrammar())
print(highlighter.highlight(code))
