//
//  Pattern.swift
//  SyntaxKit
//
//  Created by Sam Soffes on 9/18/14.
//  Copyright © 2014-2015 Sam Soffes. All rights reserved.
//

import Foundation

final class Pattern {

	// MARK: - Properties

	let name: String?
	let match: String?
	let captures: CaptureCollection?
	let begin: String?
	let beginCaptures: CaptureCollection?
	let end: String?
	let endCaptures: CaptureCollection?
	private weak var parent: Pattern?
	private let patterns: [Pattern]

	var superpattern: Pattern? {
		return parent
	}

	var subpatterns: [Pattern] {
		return patterns
	}

	// MARK: - Initializers

    init?(dictionary: [NSObject: AnyObject], parent: Pattern? = nil, repository: Repository? = nil) {
		self.parent = parent
		self.name = dictionary["name"] as? String
		self.match = dictionary["match"] as? String
		self.begin = dictionary["begin"] as? String
		self.end = dictionary["end"] as? String

		if let dictionary = dictionary["beginCaptures"] as? [NSObject: AnyObject] {
			self.beginCaptures = CaptureCollection(dictionary: dictionary)
		} else {
			self.beginCaptures = nil
		}

		if let dictionary = dictionary["captures"] as? [NSObject: AnyObject] {
			self.captures = CaptureCollection(dictionary: dictionary)
		} else {
			self.captures = nil
		}

		if let dictionary = dictionary["endCaptures"] as? [NSObject: AnyObject] {
			self.endCaptures = CaptureCollection(dictionary: dictionary)
		} else {
			self.endCaptures = nil
		}

		var patterns = [Pattern]()
		if let array = dictionary["patterns"] as? [[NSObject: AnyObject]] {
			for value in array {
                if let include = value["include"] as? String where include.hasPrefix("#") {
                    let key = include.substringFromIndex(include.startIndex.successor())
                    if let repo = repository, pattern = repo[key] {
                        patterns += pattern.subpatterns
                        continue
                    } else {
                        print("**** error: couldn't include pattern from repository: \(key)")
                    }
                }
                
				if let pattern = Pattern(dictionary: value, parent: parent, repository: repository) {
					patterns.append(pattern)
				}
			}
		}
		self.patterns = patterns
	}
}

extension Pattern: CustomStringConvertible {
    var description: String {
        return "<Pattern name: \(name), match: \(match), begin: \(begin), end: \(end), subpatterns: \(subpatterns)>"
    }
}
