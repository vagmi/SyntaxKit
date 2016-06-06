//
//  ParserTests.swift
//  SyntaxKit
//
//  Created by Sam Soffes on 6/15/15.
//  Copyright © 2015 Sam Soffes. All rights reserved.
//

import XCTest
@testable import SyntaxKit

class ParserTests: XCTestCase {

	// MARK: - Tests

	func testParsingBeginEnd() {
        let parser = Parser(language: language("YAML"))
        let input = "title: \"Hello World\""
        let resultSet = parser.parse(input)
        
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "string.unquoted.yaml", range: NSRange(location: 0, length: 20))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "entity.name.tag.yaml", range: NSRange(location: 0, length: 5))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.definition.string.begin.yaml", range: NSRange(location: 7, length: 1))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.definition.string.end.yaml", range: NSRange(location: 19, length: 1))))
	}

	func testParsingBeginEndCrap() {
        let parser = Parser(language: language("YAML"))
        let input = "title: Hello World\ncomments: 24\nposts: \"12\"zz\n"
        let resultSet = parser.parse(input)
	
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "string.quoted.double.yaml", range: NSRange(location: 39, length: 4))))
	}
    
    // MARK: - Ruby

	func testRuby() {
		let parser = Parser(language: language("Ruby"))
		let input = fixture("test.rb", "txt")
		let _  = parser.parse(input)
	}
    
    func testRuby_parseClass() {
        let parser = Parser(language: language("Ruby"))
        let input = "class Foo"
        let resultSet = parser.parse(input)
        
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "keyword.control.class.ruby", range: NSRange(location: 0, length: 5))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "entity.name.type.class.ruby", range: NSRange(location: 6, length: 3))))
    }
    
    // MARK: - JavaScript
    
    func testJavaScript() {
        let parser = Parser(language: language("JavaScript"))
        let input = fixture("test.js", "txt")
        let _ = parser.parse(input)
    }
    
    func testJavaScript_parseNumbers() {
        let parser = Parser(language: language("JavaScript"))
        let resultSet = parser.parse("123")
        
        XCTAssertEqual(resultSet.results[0], Result(scope: "constant.numeric.js", range: NSRange(location: 0, length: 3)))
    }
    
    func testJavaScript_parseOperators() {
        let parser = Parser(language: language("JavaScript"))
        let resultSet = parser.parse(">")
        
        XCTAssertEqual(resultSet.results[0], Result(scope: "keyword.operator.js", range: NSRange(location: 0, length: 1)))
    }
    
    func testJavaScript_parseFunctions() {
        let parser = Parser(language: language("JavaScript"))
        let input = "function bar(foo) {"
        let resultSet = parser.parse(input)
        
        printResults(resultSet.results, input: input)

        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "entity.name.function.js", range: NSRange(location: 9, length: 3))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "variable.parameter.function.js", range: NSRange(location: 13, length: 3))))
    }
    
    func testJavaScript_parseStorage() {
        let parser = Parser(language: language("JavaScript"))
        let input = "let a;"
        let resultSet = parser.parse(input)
        
        XCTAssertEqual(resultSet.results[0], Result(scope: "storage.type.js", range: NSRange(location: 0, length: 3)))
    }
    
    func testJavaScript_parseComment() {
        let parser = Parser(language: language("JavaScript"))
        let input = " // a comment"
        let resultSet = parser.parse(input)
        
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.whitespace.comment.leading.js", range: NSRange(location: 0, length: 1))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "comment.line.double-slash.js", range: NSRange(location: 1, length: 12))))
    }

    func testJavaScript_parseCommentBlock() {
        let parser = Parser(language: language("JavaScript"))
        let input = "/* foo */"
        let resultSet = parser.parse(input)
        
        XCTAssertEqual(resultSet.results.count, 3)
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.definition.comment.js", range: NSRange(location: 0, length: 2))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "comment.block.js", range: NSRange(location: 0, length: 9))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.definition.comment.js", range: NSRange(location: 7, length: 2))))
    }
    
    func testJavaScript_parseMultilineComment() {
        let parser = Parser(language: language("JavaScript"))
        let input = "/* a\ncomment */"
        let resultSet = parser.parse(input)
        
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "comment.block.js", range: NSRange(location: 0, length: 4))))
    }
    
    func testJavaScript_parseString() {
        let parser = Parser(language: language("JavaScript"))
        let input = "\"foo\""
        let resultSet = parser.parse(input)
        
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "string.quoted.double.js", range: NSRange(location: 0, length: 5))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.definition.string.begin.js", range: NSRange(location: 0, length: 1))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.definition.string.end.js", range: NSRange(location: 4, length: 1))))
    }
    
    func testJavaScript_parseAssignment() {
        let parser = Parser(language: language("JavaScript"))
        let input = "var a = 10;"
        let resultSet = parser.parse(input)
        
        XCTAssertEqual(resultSet.results.count, 4)
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "constant.numeric.js", range: NSRange(location: 8, length: 2))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "storage.type.js", range: NSRange(location: 0, length: 3))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "keyword.operator.js", range: NSRange(location: 6, length: 1))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.terminator.statement.js", range: NSRange(location: 10, length: 1))))
    }
}