//
//  EnumsTests.swift
//
//  Created by Marco Capano on 06/04/2020.
//
//  Thanks to https://nshipster.com/ns_enum-ns_options/ for a really useful article on Objective-C enums ❤️

import XCTest
import Splash
@testable import SplashObjc

class EnumsTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testSimpleIntegerValuesEnum() {
        let components = highlighter.highlight("""
        enum {
            UITableViewCellStyleDefault,
            UITableViewCellStyleValue1,
            UITableViewCellStyleValue2,
            UITableViewCellStyleSubtitle
        };
        """)

        XCTAssertEqual(components, [
            .token("enum", .keyword),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .plainText("UITableViewCellStyleDefault,"),
            .whitespace("\n    "),
            .plainText("UITableViewCellStyleValue1,"),
            .whitespace("\n    "),
            .plainText("UITableViewCellStyleValue2,"),
            .whitespace("\n    "),
            .plainText("UITableViewCellStyleSubtitle"),
            .whitespace("\n"),
            .plainText("};")
        ])
    }

    func testTypedefEnum() {
        let components = highlighter.highlight("""
        typedef enum {
            UITableViewCellStyleDefault,
            UITableViewCellStyleValue1,
            UITableViewCellStyleValue2,
            UITableViewCellStyleSubtitle
        } UITableViewCellStyle;
        """)

        XCTAssertEqual(components, [
            .token("typedef", .keyword),
            .whitespace(" "),
            .token("enum", .keyword),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .plainText("UITableViewCellStyleDefault,"),
            .whitespace("\n    "),
            .plainText("UITableViewCellStyleValue1,"),
            .whitespace("\n    "),
            .plainText("UITableViewCellStyleValue2,"),
            .whitespace("\n    "),
            .plainText("UITableViewCellStyleSubtitle"),
            .whitespace("\n"),
            .plainText("}"),
            .whitespace(" "),
            .plainText("UITableViewCellStyle;")
        ])
    }
}
