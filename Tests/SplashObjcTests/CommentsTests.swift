//
//  CommentsTests.swift
//  
//
//  Created by Marco Capano on 05/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class CommentsTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testSingleLineComment() {
        let components = highlighter.highlight("int n = 24; // Hello [object callFunction] NSString *s = @\"\";")

        XCTAssertEqual(components, [
            .token("int", .keyword),
            .whitespace(" "),
            .plainText("n"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("24", .number),
            .plainText(";"),
            .whitespace(" "),
            .token("//", .comment),
            .whitespace(" "),
            .token("Hello", .comment),
            .whitespace(" "),
            .token("[object", .comment),
            .whitespace(" "),
            .token("callFunction]", .comment),
            .whitespace(" "),
            .token("NSString", .comment),
            .whitespace(" "),
            .token("*s", .comment),
            .whitespace(" "),
            .token("=", .comment),
            .whitespace(" "),
            .token("@\"\";", .comment)
        ])
    }

    func testMultiLineComment() {
        let components = highlighter.highlight("""
        @implementation Person
        /* Comment
            Hello!
        */ [object callFunction]
        @end
        """)

        XCTAssertEqual(components, [
            .token("@implementation", .keyword),
            .whitespace(" "),
            .plainText("Person"),
            .whitespace("\n"),
            .token("/*", .comment),
            .whitespace(" "),
            .token("Comment", .comment),
            .whitespace("\n    "),
            .token("Hello!", .comment),
            .whitespace("\n"),
            .token("*/", .comment),
            .whitespace(" "),
            .plainText("[object"),
            .whitespace(" "),
            .token("callFunction", .call),
            .plainText("]"),
            .whitespace("\n"),
            .token("@end", .keyword)
        ])
    }

    func testCommentEndingWithSemicolon() {
        let components = highlighter.highlight("""
        // Hello;
        @implementation Person
        @end
        """)

        XCTAssertEqual(components, [
            .token("//", .comment),
            .whitespace(" "),
            .token("Hello;", .comment),
            .whitespace("\n"),
            .token("@implementation", .keyword),
            .whitespace(" "),
            .plainText("Person"),
            .whitespace("\n"),
            .token("@end", .keyword)
        ])
    }

    func testCommentWithNumber() {
        let components = highlighter.highlight("// 1")

        XCTAssertEqual(components, [
            .token("//", .comment),
            .whitespace(" "),
            .token("1", .comment)
        ])
    }

    func testCommentWithNoWhiteSpaceToPunctuation() {
        let components = highlighter.highlight(";// World")

         XCTAssertEqual(components, [
            .plainText(";"),
            .token("//", .comment),
            .whitespace(" "),
            .token("World", .comment),
        ])
    }
}

