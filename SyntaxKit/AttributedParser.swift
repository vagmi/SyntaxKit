//
//  AttributedParser.swift
//  SyntaxKit
//
//  Created by Sam Soffes on 9/24/14.
//  Copyright © 2014-2015 Sam Soffes. All rights reserved.
//

public let ScopeAttributeName = "SyntaxKitScopeAttributeName"

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
            guard let attributes = attributesForScope(result.scope) else { continue }

            var effectiveRange = NSRange(location: result.range.location, length: 0)
            if let existingScope = output.attribute(ScopeAttributeName, atIndex: result.range.location, effectiveRange: &effectiveRange) as? String {
                let hasExistingScopeForRange = NSEqualRanges(effectiveRange, result.range)
                
                if (hasExistingScopeForRange && specificityForScope(existingScope) <= specificityForScope(result.scope)) || !hasExistingScopeForRange {
                    // Only add scope if there isn't an existing scope for this range, or if the current scope is less specific
                    output.addAttributes(attributes, range: result.range)
                }
            } else {
                // No existing scope
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
        
        // Search through least specific to most specific variants of the scope
        for i in 1..<components.count {
            let key = components[0..<i].joinWithSeparator(".")
            if let attrs = theme.attributes[key] {
                for (k, v) in attrs {
                    attributes[k] = v
                }
            }
        }
        
        if !attributes.isEmpty {
            attributes[ScopeAttributeName] = scope
            return attributes
        } else {
            return nil
        }
	}
    
    private func specificityForScope(scope: String) -> Int {
        // The more components a scope has, the more specific it is
        return scope.componentsSeparatedByString(".").count
    }
}
