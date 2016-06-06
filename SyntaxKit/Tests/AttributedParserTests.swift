//
//  AttributedParserTests.swift
//  SyntaxKitTests
//
//  Created by Sam Soffes on 9/19/14.
//  Copyright © 2014-2015 Sam Soffes. All rights reserved.
//

import XCTest
import SyntaxKit

class AttributedParserTests: XCTestCase {

	// MARK: - Tests

	func testParsingYAML() {
        let parser = AttributedParser(language: language("YAML"), theme: simpleTheme())
        let input = "title: Hello World\ncount: 42\n"
		let string = parser.attributedStringForString(input)
        
        XCTAssertEqual(string.attribute("color", atIndex: 0, effectiveRange: nil) as? String, "blue")
		XCTAssertEqual(string.attribute("color", atIndex: 7, effectiveRange: nil) as? String, "red")
		XCTAssertEqual(string.attribute("color", atIndex: 19, effectiveRange: nil) as? String, "blue")
		XCTAssertEqual(string.attribute("color", atIndex: 25, effectiveRange: nil) as? String, "purple")
	}

    func testParsingRuby() {
        let parser = AttributedParser(language: language("Ruby"), theme: simpleTheme())
        let input = "class Foo\nend"
        let string = parser.attributedStringForString(input)
        
        XCTAssertEqual(string.attribute("color", atIndex: 0, effectiveRange: nil) as? String, "green")
        XCTAssertEqual(string.attribute("color", atIndex: 6, effectiveRange: nil) as? String, "blue")
        XCTAssertEqual(string.attribute("color", atIndex: 10, effectiveRange: nil) as? String, "green")
    }
    
    func testParsingJavaScript() {
        let parser = AttributedParser(language: language("JavaScript"), theme: simpleTheme())
        let input = "var a = 1;"
        let string = parser.attributedStringForString(input)
        
        XCTAssertEqual(string.attribute("color", atIndex: 0, effectiveRange: nil) as? String, "orange")
        XCTAssertEqual(string.attribute("color", atIndex: 6, effectiveRange: nil) as? String, "green")
        XCTAssertEqual(string.attribute("color", atIndex: 8, effectiveRange: nil) as? String, "purple")
    }
}
