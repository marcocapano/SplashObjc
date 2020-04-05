//
//  Mocks.swift
//  
//
//  Created by Marco Capano on 05/04/2020.
//
import Splash

struct OutputBuilderMock: OutputBuilder {
    private var components = [Component]()

    mutating func addToken(_ token: String, ofType type: TokenType) {
        components.append(.token(token, type))
    }

    mutating func addPlainText(_ text: String) {
        components.append(.plainText(text))
    }

    mutating func addWhitespace(_ whitespace: String) {
        components.append(.whitespace(whitespace))
    }

    func build() -> [Component] {
        return components
    }
}

extension OutputBuilderMock {
    enum Component: Equatable {
        case token(String, TokenType)
        case plainText(String)
        case whitespace(String)
    }
}

struct OutputFormatMock: OutputFormat {
    let builder: OutputBuilderMock

    func makeBuilder() -> OutputBuilderMock {
        return builder
    }
}
