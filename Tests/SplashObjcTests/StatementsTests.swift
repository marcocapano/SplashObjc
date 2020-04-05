//
//  StatementsTests.swift
//  
//
//  Created by Marco Capano on 05/04/2020.
//
import XCTest
import Splash
@testable import SplashObjc

final class StatementTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testChainedIfElseStatements() {
        let components = highlighter.highlight("""
        if (condition) {
        } else if ([self call]) {
        } else {
        }
        """)

        XCTAssertEqual(components, [
            .token("if", .keyword),
            .whitespace(" "),
            .plainText("(condition)"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n"),
            .plainText("}"),
            .whitespace(" "),
            .token("else", .keyword),
            .whitespace(" "),
            .token("if", .keyword),
            .whitespace(" "),
            .plainText("(["),
            .token("self", .keyword),
            .whitespace(" "),
            .token("call", .call),
            .plainText("])"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n"),
            .plainText("}"),
            .whitespace(" "),
            .token("else", .keyword),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n"),
            .plainText("}")
        ])
    }

    func testSwitchStatement() {
        let components = highlighter.highlight("""
        switch(letter) {
        case 'a':
            break;
        default:
            break;
        }
        """)

        XCTAssertEqual(components, [
            .token("switch", .keyword),
            .plainText("(letter)"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n"),
            .token("case", .keyword),
            .whitespace(" "),
            .token("'a'", .number),
            .plainText(":"),
            .whitespace("\n    "),
            .token("break", .keyword),
            .plainText(";"),
            .whitespace("\n"),
            .token("default", .keyword),
            .plainText(":"),
            .whitespace("\n    "),
            .token("break", .keyword),
            .plainText(";"),
            .whitespace("\n"),
            .plainText("}"),
        ])
    }

    func testForStatement() {
        let components = highlighter.highlight("""
        for (int i = 0; i < 10; i++) {
            [object doStuff];
        }
        """)

        XCTAssertEqual(components, [
            .token("for", .keyword),
            .whitespace(" "),
            .plainText("("),
            .token("int", .keyword),
            .whitespace(" "),
            .plainText("i"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("0", .number),
            .plainText(";"),
            .whitespace(" "),
            .plainText("i"),
            .whitespace(" "),
            .plainText("<"),
            .whitespace(" "),
            .token("10", .number),
            .plainText(";"),
            .whitespace(" "),
            .plainText("i++)"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .plainText("[object"),
            .whitespace(" "),
            .token("doStuff", .call),
            .plainText("];"),
            .whitespace("\n"),
            .plainText("}")
        ])
    }

    func testDoWhileStatement() {
        let components = highlighter.highlight("""
        do {
            //code
        } while (condition);
        """)

        XCTAssertEqual(components, [
            .token("do", .keyword),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .token("//code", .comment),
            .whitespace("\n"),
            .plainText("}"),
            .whitespace(" "),
            .token("while", .keyword),
            .whitespace(" "),
            .plainText("(condition);")
        ])
    }
}
