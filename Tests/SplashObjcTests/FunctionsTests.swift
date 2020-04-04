//
//  FunctionsTests.swift
//  
//
//  Created by Marco Capano on 04/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class FunctionsTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testAllocInit() {
        let components = highlighter.highlight("self.view = [UIView alloc] init];")

        XCTAssertEqual(components, [
            .token("self", .keyword),
            .plainText("."),
            .token("view", .property),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .plainText("["),
            .token("UIView", .type),
            .whitespace(" "),
            .token("alloc", .call),
            .plainText("]"),
            .whitespace(" "),
            .token("init", .call),
            .plainText("];")
        ])
    }

    func testFunctionDeclarationNoArguments() {
        let components = highlighter.highlight("- (void)someMethod;")

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("void", .keyword),
            .plainText(")someMethod;")
        ])
    }

    func testFunctionDefinitionNoArguments() {
        let components = highlighter.highlight("""
        - (void)someMethod {
            int number = 5;
        }
        """)

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("void", .keyword),
            .plainText(")someMethod"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .token("int", .keyword),
            .whitespace(" "),
            .plainText("number"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("5", .number),
            .plainText(";"),
            .whitespace("\n"),
            .plainText("}")
        ])
    }

    func testFunctionDeclarationWithOneObjectArgument() {
        let components = highlighter.highlight("- (NSString *)titleForArticle:(Article *)article;")

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*)titleForArticle:("),
            .token("Article", .type),
            .whitespace(" "),
            .plainText("*)article;"),
        ])
    }

    func testFunctionDefinitionWithOneObjectArgument() {
        let components = highlighter.highlight("""
        - (NSString *)titleForArticle:(Article *)article {
            return article.title;
        }
        """)

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*)titleForArticle:("),
            .token("Article", .type),
            .whitespace(" "),
            .plainText("*)article"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .token("return", .keyword),
            .whitespace(" "),
            .plainText("article."),
            .token("title", .property),
            .plainText(";"),
            .whitespace("\n"),
            .plainText("}")
        ])
    }

    func testFunctionDeclarationWithOnePrimitiveArgument() {
        let components = highlighter.highlight("- (NSString *)titleForRank:(int)rank;")

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*)titleForRank:("),
            .token("int", .keyword),
            .plainText(")rank;"),
        ])
    }

    func testFunctionDefinitionWithOnePrimitiveArgument() {
        let components = highlighter.highlight("""
        - (NSString *)titleForRank:(int)rank {
            return @"Title";
        }
        """)

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*)titleForRank:("),
            .token("int", .keyword),
            .plainText(")rank"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .token("return", .keyword),
            .whitespace(" "),
            .token("@\"Title\"", .string),
            .plainText(";"),
            .whitespace("\n"),
            .plainText("}")
        ])
    }

    func testFunctionDeclarationWithMultipleArguments() {
        let components = highlighter.highlight("- (int)max:(int)num1 andNum2:(int)num2;")

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("int", .keyword),
            .plainText(")max:("),
            .token("int", .keyword),
            .plainText(")num1"),
            .whitespace(" "),
            .plainText("andNum2:("),
            .token("int", .keyword),
            .plainText(")num2;")
        ])
    }

    func testFunctionDefinitionWithMultipleArguments() {
        let components = highlighter.highlight("""
        - (int)max:(int)num1 andNum2:(int)num2 {
            if (num1 > num2) {
                return num1;
            else {
                return num2;
            }
        }
        """)

        XCTAssertEqual(components, [
            .plainText("-"),
            .whitespace(" "),
            .plainText("("),
            .token("int", .keyword),
            .plainText(")max:("),
            .token("int", .keyword),
            .plainText(")num1"),
            .whitespace(" "),
            .plainText("andNum2:("),
            .token("int", .keyword),
            .plainText(")num2"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n    "),
            .token("if", .keyword),
            .whitespace(" "),
            .plainText("(num1"),
            .whitespace(" "),
            .plainText(">"),
            .whitespace(" "),
            .plainText("num2)"),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n        "),
            .token("return", .keyword),
            .whitespace(" "),
            .plainText("num1;"),
            .whitespace("\n    "),
            .token("else", .keyword),
            .whitespace(" "),
            .plainText("{"),
            .whitespace("\n        "),
            .token("return", .keyword),
            .whitespace(" "),
            .plainText("num2;"),
            .whitespace("\n    "),
            .plainText("}"),
            .whitespace("\n"),
            .plainText("}")
        ])
    }
}
