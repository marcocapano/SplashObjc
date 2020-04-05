//
//  LiteralsTests.swift
//  
//
//  Created by Marco Capano on 01/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class LiteralsTests: XCTestCase {
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

    func testIntegerLiteral() {
        let components = highlighter.highlight("int kobe = 24;")

        XCTAssertEqual(components, [
            .token("int", .keyword),
            .whitespace(" "),
            .plainText("kobe"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("24", .number),
            .plainText(";")
        ])
    }

    func testIntegerObjectLiteral() {
        let components = highlighter.highlight("NSNumber *number = @10;")

        XCTAssertEqual(components, [
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*number"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@10", .number),
            .plainText(";")
        ])
    }

    func testUnsignedIntegerObjectLiteral() {
        let components = highlighter.highlight("NSNumber *fortyTwoUnsigned = @42U;")

        XCTAssertEqual(components, [
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*fortyTwoUnsigned"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@42U", .number),
            .plainText(";")
        ])
    }

    func testLongIntegerObjectLiteral() {
        let components = highlighter.highlight("NSNumber *fortyTwoLong = @42L;")

        XCTAssertEqual(components, [
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*fortyTwoLong"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@42L", .number),
            .plainText(";")
        ])
    }

    func testLongLongIntegerObjectLiteral() {
        let components = highlighter.highlight("NSNumber *fortyTwoLongLong = @42LL;")

        XCTAssertEqual(components, [
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*fortyTwoLongLong"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@42LL", .number),
            .plainText(";")
        ])
    }

    func testBoolObjectLiteral() {
        let components = highlighter.highlight("""
        NSNumber *yesNumber = @YES;
        NSNumber *noNumber = @NO;
        """)

        XCTAssertEqual(components, [
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*yesNumber"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@YES", .number),
            .plainText(";"),
            .whitespace("\n"),
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*noNumber"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@NO", .number),
            .plainText(";")
        ])
    }

    func testDoubleLiteral() {
        let components = highlighter.highlight("double duration = 2.0;")

        XCTAssertEqual(components, [
            .token("double", .keyword),
            .whitespace(" "),
            .plainText("duration"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("2.0", .number),
            .plainText(";")
        ])
    }

    func testFloatLiteral() {
        let components = highlighter.highlight("float duration = 2.0f;")

        XCTAssertEqual(components, [
            .token("float", .keyword),
            .whitespace(" "),
            .plainText("duration"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("2.0f", .number),
            .plainText(";")
        ])
    }

    func testDoubleObjectLiteral() {
        let components = highlighter.highlight("NSNumber *piDouble = @3.14;")

        XCTAssertEqual(components, [
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*piDouble"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@3.14", .number),
            .plainText(";")
        ])
    }

    func testFloatObject() {
        let components = highlighter.highlight("NSNumber *piFloat = @3.14F;")

        XCTAssertEqual(components, [
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*piFloat"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@3.14F", .number),
            .plainText(";")
        ])
    }

    func testCharacterLiteral() {
        let components = highlighter.highlight("char letter = 'M';")

        XCTAssertEqual(components, [
            .token("char", .keyword),
            .whitespace(" "),
            .plainText("letter"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("'M'", .number),
            .plainText(";")
        ])
    }

    func testCharacterObjectLiteral() {
        let components = highlighter.highlight("NSNumber *letter = @'M';")

        XCTAssertEqual(components, [
            .token("NSNumber", .type),
            .whitespace(" "),
            .plainText("*letter"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("@'M'", .number),
            .plainText(";")
        ])
    }

    func testStringInterpolation() {
        let components = highlighter.highlight("[NSString stringWithFormat:@\"name %@\", name];")

        XCTAssertEqual(components, [
            .plainText("["),
            .token("NSString", .type),
            .whitespace(" "),
            .token("stringWithFormat", .call),
            .plainText(":"),
            .token("@\"name", .string),
            .whitespace(" "),
            .token("%@\"", .string),
            .plainText(","),
            .whitespace(" "),
            .token("name", .call),
            .plainText("];")
        ])
    }
}
