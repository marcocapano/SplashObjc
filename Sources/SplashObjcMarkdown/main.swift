//
//  main.swift
//  
//
//  Created by Marco Capano on 13/04/2020.
//

import Foundation
import Splash
import SplashObjc

guard CommandLine.arguments.count > 1 else {
    print("⚠️  Please supply the path to a Markdown file to process as an argument")
    exit(1)
}

let markdown: String = {
    let path = CommandLine.arguments[1]

    do {
        let path = (path as NSString).expandingTildeInPath
        return try String(contentsOfFile: path)
    } catch {
        print("""
        🛑 Failed to open Markdown file at '\(path)':
        ---
        \(error.localizedDescription)
        ---
        """)
        exit(1)
    }
}()

let decorator = MarkdownDecorator(grammar: ObjcGrammar())
print(decorator.decorate(markdown))
