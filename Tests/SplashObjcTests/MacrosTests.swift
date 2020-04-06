//
//  MacrosTests.swift
//  
//
//  Created by Marco Capano on 06/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class MacrosTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testMacroCallWithArguments() {
        let components = highlighter.highlight("""
        @property NSString *name API_AVAILABLE(macos(10.5), ios(2.0));
        """)

        XCTAssertEqual(components, [
            .token("@property", .keyword),
            .whitespace(" "),
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*name"),
            .whitespace(" "),
            .token("API_AVAILABLE", .preprocessing),
            .plainText("(macos("),
            .token("10.5", .number),
            .plainText("),"),
            .whitespace(" "),
            .plainText("ios("),
            .token("2.0", .number),
            .plainText("));")
        ])
    }

    func testSimpleMacro() {
        let components = highlighter.highlight("""
        @class NSDate;

        NS_ASSUME_NONNULL_BEGIN

        @protocol NSLocking
        """)

        XCTAssertEqual(components, [
            .token("@class", .keyword),
            .whitespace(" "),
            .token("NSDate", .type),
            .plainText(";"),
            .whitespace("\n\n"),
            .token("NS_ASSUME_NONNULL_BEGIN", .preprocessing),
            .whitespace("\n\n"),
            .token("@protocol", .keyword),
            .whitespace(" "),
            .token("NSLocking", .type)
        ])
    }

    func testAllUppercasesKeywordsAreNotTreatedAsMacros() {
        let components = highlighter.highlight("- (BOOL)tryLock;")

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("BOOL", .keyword),
            .plainText(")tryLock;")
        ])
    }
}
