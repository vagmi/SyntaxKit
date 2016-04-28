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

		XCTAssertEqual(["color": "blue"] as NSDictionary, string.attributesAtIndex(0, effectiveRange: nil) as NSDictionary)
		XCTAssertEqual(["color": "red"] as NSDictionary, string.attributesAtIndex(7, effectiveRange: nil) as NSDictionary)
		XCTAssertEqual(["color": "blue"] as NSDictionary, string.attributesAtIndex(19, effectiveRange: nil) as NSDictionary)
		XCTAssertEqual(["color": "purple"] as NSDictionary, string.attributesAtIndex(25, effectiveRange: nil) as NSDictionary)
	}
    
    func testParsingJavaScript() {
        let parser = AttributedParser(language: language("JavaScript"), theme: simpleTheme())
        let input = "var a = 1;"

        let string = parser.attributedStringForString(input)
        
        XCTAssertEqual(["color": "orange"] as NSDictionary, string.attributesAtIndex(0, effectiveRange: nil) as NSDictionary)
        XCTAssertEqual(["color": "green"] as NSDictionary, string.attributesAtIndex(6, effectiveRange: nil) as NSDictionary)
        XCTAssertEqual(["color": "purple"] as NSDictionary, string.attributesAtIndex(8, effectiveRange: nil) as NSDictionary)
    }
    
    func testParsingJavaScriptTomorrowTheme() {
        let path = "/Users/zach/Desktop/tomorrow-night.tmTheme"
        let dict = NSDictionary(contentsOfFile: path)! as [NSObject: AnyObject]
        let theme = Theme(dictionary: dict)!
        
        let parser = AttributedParser(language: language("JavaScript"), theme: theme)
        let input = "var a = 1;"
        
        let _ = parser.attributedStringForString(input)
        //print("\(string)")
        
        //XCTAssertEqual(["color": "orange"] as NSDictionary, string.attributesAtIndex(0, effectiveRange: nil) as NSDictionary)
        //XCTAssertEqual(["color": "green"] as NSDictionary, string.attributesAtIndex(6, effectiveRange: nil) as NSDictionary)
        //XCTAssertEqual(["color": "purple"] as NSDictionary, string.attributesAtIndex(8, effectiveRange: nil) as NSDictionary)
    }
}
