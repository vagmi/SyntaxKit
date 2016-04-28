//
//  AttributedParser.swift
//  SyntaxKit
//
//  Created by Sam Soffes on 9/24/14.
//  Copyright © 2014-2015 Sam Soffes. All rights reserved.
//

public class AttributedParser: Parser {

	// MARK: - Types

	public typealias AttributedCallback = (scope: String, range: NSRange, attributes: Attributes?) -> Void


	// MARK: - Properties

	public let theme: Theme


	// MARK: - Initializers

	public required init(language: Language, theme: Theme) {
		self.theme = theme
		super.init(language: language)
	}


	// MARK: - Parsing

	public func attributedStringForString(string: String, baseAttributes: Attributes? = nil) -> NSAttributedString {
        let resultSet = parse(string)
		let output = NSMutableAttributedString(string: string, attributes: baseAttributes)
        
        for result in resultSet.results {
            if let attributes = attributesForScope(result.scope) {
                output.addAttributes(attributes, range: result.range)
            }
        }

		return output
	}


	// MARK: - Private

	private func attributesForScope(scope: String) -> Attributes? {
		let components = scope.componentsSeparatedByString(".")
        
		guard components.count > 0 else {
			return nil
		}
        
		var attributes = Attributes()
        for i in 1..<components.count {
            let key = components[0..<i].joinWithSeparator(".")
            if let attrs = theme.attributes[key] {
                for (k, v) in attrs {
                    attributes[k] = v
                }
            }
        }

		if attributes.isEmpty {
			return nil
		}

		return attributes
	}
}
