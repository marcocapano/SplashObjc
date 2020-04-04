//
//  Functions.swift
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
            .plainText(";")
        ])
    }

    //- (int)max:(int)num1 andNum2:(int)num2;
   // - (int)max:(int)num1 andNum2:(int)num2 {
}
