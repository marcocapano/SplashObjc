//
//  ClassesTests.swift
//
//
//  Created by Marco Capano on 01/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class ClassesTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testClassHeader() {
        let code = """
        @interface Person : NSObject

        @property NSString *firstName;
        @property int yearOfBirth;

        @end
        """

        let components = highlighter.highlight(code)
        XCTAssertEqual(components, [
            .token("@interface", .keyword),
            .whitespace(" "),
            .plainText("Person"),
            .whitespace(" "),
            .plainText(":"),
            .whitespace(" "),
            .token("NSObject", .type),
            .whitespace("\n\n"),
            .token("@property", .keyword),
            .whitespace(" "),
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*firstName;"),
            .whitespace("\n"),
            .token("@property", .keyword),
            .whitespace(" "),
            .token("int", .keyword),
            .whitespace(" "),
            .plainText("yearOfBirth;"),
            .whitespace("\n\n"),
            .token("@end", .keyword)
        ])
    }

    func testClassPrivateInterface() {
        let code = """
        @interface Person ()

        long int privateProperty;

        @end
        """

        let components = highlighter.highlight(code)
        XCTAssertEqual(components, [
            .token("@interface", .keyword),
            .whitespace(" "),
            .plainText("Person"),
            .whitespace(" "),
            .plainText("()"),
            .whitespace("\n\n"),
            .token("long", .keyword),
            .whitespace(" "),
            .token("int", .keyword),
            .whitespace(" "),
            .plainText("privateProperty;"),
            .whitespace("\n\n"),
            .token("@end", .keyword),
        ])
    }

    func testClassImplementation() {
        let code = """
        @implementation Person
        @end
        """

        let components = highlighter.highlight(code)
        XCTAssertEqual(components, [
            .token("@implementation", .keyword),
            .whitespace(" "),
            .plainText("Person"),
            .whitespace("\n"),
            .token("@end", .keyword)
        ])
    }
}
