//
//  LiteralsTests.swift
//  
//
//  Created by Marco Capano on 01/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class LiteralTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testStringLiteral() {
        let components = highlighter.highlight("NSString *name = @\"Name\";")

        XCTAssertEqual(components, [
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*name"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@\"Name\"", .string),
            .plainText(";")
        ])
    }
}

//MARK: - Mocks

struct OutputBuilderMock: OutputBuilder {
    private var components = [Component]()

    mutating func addToken(_ token: String, ofType type: TokenType) {
        components.append(.token(token, type))
    }

    mutating func addPlainText(_ text: String) {
        components.append(.plainText(text))
    }

    mutating func addWhitespace(_ whitespace: String) {
        components.append(.whitespace(whitespace))
    }

    func build() -> [Component] {
        return components
    }
}

extension OutputBuilderMock {
    enum Component: Equatable {
        case token(String, TokenType)
        case plainText(String)
        case whitespace(String)
    }
}

struct OutputFormatMock: OutputFormat {
    let builder: OutputBuilderMock

    func makeBuilder() -> OutputBuilderMock {
        return builder
    }
}
