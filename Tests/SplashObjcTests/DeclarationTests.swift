//
//  ClassesTests.swift
//
//
//  Created by Marco Capano on 01/04/2020.
//

import XCTest
import Splash
@testable import SplashObjc

class DeclarationTests: XCTestCase {
    private(set) var highlighter: SyntaxHighlighter<OutputFormatMock>!
    private(set) var builder: OutputBuilderMock!

    override func setUp() {
        super.setUp()
        builder = OutputBuilderMock()

        let format = OutputFormatMock(builder: builder)
        highlighter = SyntaxHighlighter(format: format, grammar: ObjcGrammar())
    }

    func testEmptyClassDeclaration() {

    }
}
