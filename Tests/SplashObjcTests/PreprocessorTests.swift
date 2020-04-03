//
//  PreprocessorTests.swift
//  
//
//  Created by Marco Capano on 03/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class PreprocessorTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testDefineNumber() {
        let components = highlighter.highlight("#define MAX_ARRAY_LENGTH 20")

        XCTAssertEqual(components, [
            .token("#define", .preprocessing),
            .whitespace(" "),
            .token("MAX_ARRAY_LENGTH", .preprocessing),
            .whitespace(" "),
            .token("20", .preprocessing)
        ])
    }

    func testDefineString() {
        let components = highlighter.highlight("#define MAX_ARRAY_LENGTH 20")

        XCTAssertEqual(components, [
            .token("#define", .preprocessing),
            .whitespace(" "),
            .token("MAX_ARRAY_LENGTH", .preprocessing),
            .whitespace(" "),
            .token("20", .preprocessing)
        ])
    }
}
