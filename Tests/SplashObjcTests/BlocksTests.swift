//
//  BlocksTests.swift
//  
//
//  Created by Marco Capano on 05/04/2020.
//  I of course do not remember all the ways you can declare a block in Objective-C.
//  Luckily http://fuckingblocksyntax.com exists ❤️
//

import XCTest
import Splash
@testable import SplashObjc

class BlocksTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testBlockAsLocalVariable() {
        let components = highlighter.highlight("""
        void (^blockName)(ParameterType parameter) = ^(ParameterType parameter) {
            [parameter doStuff];
        };
        """)

        XCTAssertEqual(components, [
            .token("void", .keyword),
            .whitespace(" "),
            .plainText("(^blockName)("),
            .token("ParameterType", .type),
            .whitespace(" "),
            .plainText("parameter)"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .plainText("^("),
            .token("ParameterType", .type),
            .whitespace(" "),
            .plainText("parameter)"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .plainText("[parameter"),
            .whitespace(" "),
            .token("doStuff", .call),
            .plainText("];"),
            .whitespace("\n"),
            .plainText("};")
        ])
    }

    func testBlockAsAProperty() {
        let components = highlighter.highlight("""
        @property (nonatomic, copy) void (^blockName)(ParameterType);
        """)

        XCTAssertEqual(components, [
            .token("@property", .keyword),
            .whitespace(" "),
            .plainText("("),
            .token("nonatomic", .keyword),
            .plainText(","),
            .whitespace(" "),
            .token("copy", .keyword),
            .plainText(")"),
            .whitespace(" "),
            .token("void", .keyword),
            .whitespace(" "),
            .plainText("(^blockName)("),
            .token("ParameterType", .type),
            .plainText(");")
        ])
    }

    func testBlockAsAMethodParameter() {
        let components = highlighter.highlight("""
        - (void)someMethodThatTakesABlock:(ReturnType (^_Nonnull)(ParameterType))blockName;
        """)

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("void", .keyword),
            .plainText(")someMethodThatTakesABlock:("),
            .token("ReturnType", .type),
            .whitespace(" "),
            .plainText("(^"),
            .token("_Nonnull", .keyword),
            .plainText(")("),
            .token("ParameterType", .type),
            .plainText("))blockName;")
        ])
    }

    func testBlockAsAnArgumentToAMethodCall() {
        let components = highlighter.highlight("""
        [someObject someMethodThatTakesABlock:^ReturnType (NSString *s) {
            NSString *string;
        }];
        """)

        XCTAssertEqual(components, [
            .plainText("[someObject"),
            .whitespace(" "),
            .token("someMethodThatTakesABlock", .call),
            .plainText(":^"),
            .token("ReturnType", .type),
            .whitespace(" "),
            .plainText("("),
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*s)"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*string;"),
            .whitespace("\n"),
            .plainText("}];")
        ])
    }

    func testAsTypedef() {
        let components = highlighter.highlight("typedef void (^CompletionHandler)(void);")

        XCTAssertEqual(components, [
            .token("typedef", .keyword),
            .whitespace(" "),
            .token("void", .keyword),
            .whitespace(" "),
            .plainText("(^"),
            .token("CompletionHandler", .type),
            .plainText(")("),
            .token("void", .keyword),
            .plainText(");")
        ])
    }
}
