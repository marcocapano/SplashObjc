//
//  Property.swift
//  
//
//  Created by Marco Capano on 04/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class PropertyTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testDotAccess() {
        let components = highlighter.highlight("frame.size = someSize;")

        XCTAssertEqual(components, [
            .plainText("frame."),
            .token("size", .property),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .plainText("someSize;")
        ])
    }

    func testNestedDotAccess() {
        let components = highlighter.highlight("NSString *bestFriendName = user.bestFriend.name;")

        XCTAssertEqual(components, [
            .token("NSString", .type),
            .whitespace(" "),
            .plainText("*bestFriendName"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .plainText("user."),
            .token("bestFriend", .property),
            .plainText("."),
            .token("name", .property),
            .plainText(";")
        ])
    }
}


