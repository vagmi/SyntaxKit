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

		var stringQuoted: NSRange?
		var punctuationBegin: NSRange?
		var punctuationEnd: NSRange?

		let resultSet = parser.parse("title: \"Hello World\"\n")
            
        for result in resultSet.results {
            if stringQuoted == nil && result.scope.hasPrefix("string.quoted.double") {
                stringQuoted = result.range
            }
            
            if punctuationBegin == nil && result.scope.hasPrefix("punctuation.definition.string.begin") {
                punctuationBegin = result.range
            }
            
            if punctuationEnd == nil && result.scope.hasPrefix("punctuation.definition.string.end") {
                punctuationEnd = result.range
            }
        }

	
		XCTAssertEqual(NSMakeRange(7, 13), stringQuoted!)
		XCTAssertEqual(NSMakeRange(7, 1), punctuationBegin!)
		XCTAssertEqual(NSMakeRange(19, 1), punctuationEnd!)
	}

	func testParsingBeginEndCrap() {
        let parser = Parser(language: language("YAML"))

		var stringQuoted: NSRange?

		let resultSet = parser.parse("title: Hello World\ncomments: 24\nposts: \"12\"zz\n")
        
        for result in resultSet.results {
			if stringQuoted == nil && result.scope.hasPrefix("string.quoted.double") {
				stringQuoted = result.range
			}
		}
	
		XCTAssertEqual(NSMakeRange(39, 4), stringQuoted!)
	}

	func testRuby() {
		let parser = Parser(language: language("Ruby"))
		let input = fixture("test.rb", "txt")
		let _  = parser.parse(input)
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
        
        print(resultSet)
        
        XCTAssertEqual(resultSet.results[0], Result(scope: "keyword.operator.js", range: NSRange(location: 0, length: 1)))
    }
    
    func testJavaScript_parseFunctions() {
        let parser = Parser(language: language("JavaScript"))
        let input = "function bar(foo) {"
        let resultSet = parser.parse(input)
        
        printResults(resultSet.results, input: input)
        
        //XCTAssertEqual(results[0], Result(scope: "keyword.operator.js", range: NSRange(location: 0, length: 1)))
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
        
        printResults(resultSet.results, input: input)
        
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.whitespace.comment.leading.js", range: NSRange(location: 0, length: 1))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "comment.line.double-slash.js", range: NSRange(location: 1, length: 12))))
    }

    func testJavaScript_parseCommentBlock() {
        let parser = Parser(language: language("JavaScript"))
        let input = "/* a comment */"
        let resultSet = parser.parse(input)
        
        printResults(resultSet.results, input: input)
        
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "comment.block.js", range: NSRange(location: 0, length: 15))))
    }
    
    func testJavaScript_parseMultilineComment() {
        let parser = Parser(language: language("JavaScript"))
        let input = "/* a\ncomment */"
        let resultSet = parser.parse(input)
        
        printResults(resultSet.results, input: input)
        
        XCTAssertEqual(resultSet.results.count, 2)
        //XCTAssertEqual(results[0], Result(scope: "comment.js", range: NSRange(location: 0, length: 2)))
    }
    
    func testJavaScript_parseString() {
        let parser = Parser(language: language("JavaScript"))
        let input = "\"foo\""
        let resultSet = parser.parse(input)
        
        printResults(resultSet.results, input: input)
        
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "string.quoted.double.js", range: NSRange(location: 0, length: 5))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.definition.string.begin.js", range: NSRange(location: 0, length: 1))))
        XCTAssertNotNil(resultSet.results.indexOf(Result(scope: "punctuation.definition.string.end.js", range: NSRange(location: 4, length: 1))))
    }
    
    func testJavaScript_parseAssignment() {
        let parser = Parser(language: language("JavaScript"))
        let input = "var a = 10;"
        let resultSet = parser.parse(input)
        
        printResults(resultSet.results, input: input)
        
        XCTAssertEqual(resultSet.results.count, 4)
        
        // TODO: don't depend on order of rules
        XCTAssertEqual(resultSet.results[0], Result(scope: "constant.numeric.js", range: NSRange(location: 8, length: 2)))
        XCTAssertEqual(resultSet.results[1], Result(scope: "storage.type.js", range: NSRange(location: 0, length: 3)))
        XCTAssertEqual(resultSet.results[2], Result(scope: "keyword.operator.js", range: NSRange(location: 6, length: 1)))
        XCTAssertEqual(resultSet.results[3], Result(scope: "punctuation.terminator.statement.js", range: NSRange(location: 10, length: 1)))
    }
}