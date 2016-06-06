//
//  Parser.swift
//  SyntaxKit
//
//  Created by Sam Soffes on 9/19/14.
//  Copyright © 2014-2015 Sam Soffes. All rights reserved.
//

import Foundation

public class Parser {

	// MARK: - Properties

	public let language: Language


	// MARK: - Initializers

	public init(language: Language) {
		self.language = language
	}


	// MARK: - Parsing

	public func parse(string: String) -> ResultSet {
		// Loop through paragraphs
		let s: NSString = string
		let length = s.length
		var paragraphEnd = 0

        var resultSet = ResultSet()
        
		while paragraphEnd < length {
			var paragraphStart = 0
			var contentsEnd = 0
			s.getParagraphStart(&paragraphStart, end: &paragraphEnd, contentsEnd: &contentsEnd, forRange: NSMakeRange(paragraphEnd, 0))

            let paragraphRange = NSRange(location: paragraphStart, length: contentsEnd - paragraphStart)
			let range = paragraphRange
            let paragraphResults = parseLine(string, inRange: range)
            resultSet.addResults(paragraphResults)
		}
        
        return resultSet
	}
    
    public func parseLine(line: String, inRange bounds: NSRange) -> ResultSet {
        var resultSet = ResultSet()
        
        for pattern in language.patterns {
            if let results = resultsForPattern(pattern, line: line, bounds: bounds) {
                resultSet.addResults(results)
            }
        }
        
        return resultSet
    }

	// MARK: - Private
    
    private func resultsForPattern(pattern: Pattern, line: String, bounds: NSRange) -> ResultSet? {
        // Single pattern
        if let match = pattern.match, matches = matchesForString(line, bounds: bounds, pattern: match) where !matches.isEmpty {
            var resultSet = ResultSet()
            
            if let scope = pattern.name {
                matches.forEach { resultSet.addResult(Result(scope: scope, range: $0.range)) }
            }
            
            // Assign captures
            if let captures = pattern.captures {
                matches.forEach {
                    if let results = captureResultsForMatch($0, captures: captures) {
                        resultSet.addResults(results)
                    }
                }
            }
            
            for pattern in pattern.subpatterns {
                if let results = resultsForPattern(pattern, line: line, bounds: bounds) {
                    resultSet.addResults(results)
                }
            }
            
            return resultSet
        }
        
        // Begin & end
        if let beginPattern = pattern.begin, endPattern = pattern.end, beginMatches = matchesForString(line, bounds: bounds, pattern: beginPattern) where !beginMatches.isEmpty {
            let beginMatch = beginMatches.first!
            let beginRange = beginMatch.range
            var resultSet = ResultSet()
            let endStart = NSMaxRange(beginMatch.range)
            let endBounds = NSRange(location: endStart, length: NSMaxRange(bounds) - endStart)
            let endMatches = matchesForString(line, bounds: endBounds, pattern: endPattern)
            let endMatch = endMatches?.first
            let endRange = endMatch?.range ?? NSRange(location: NSMaxRange(bounds), length: 0)
            
            // Assign scope to entire matching range
            if let scope = pattern.name {
                let fullRange = NSUnionRange(beginRange, endRange)
                let result = Result(scope: scope, range: fullRange)
                resultSet.addResult(result)
            }
            
            // Assign begin captures
            if let captures = pattern.beginCaptures ?? pattern.captures {
                beginMatches.forEach {
                    if let results = captureResultsForMatch($0, captures: captures) {
                        resultSet.addResults(results)
                    }
                }
            }
            
            // Assign end captures
            if let endMatches = endMatches, captures = pattern.endCaptures ?? pattern.captures {
                endMatches.forEach {
                    if let results = captureResultsForMatch($0, captures: captures) {
                        resultSet.addResults(results)
                    }
                }
            }
            
            // Check sub-patterns
            
            let innerLocation = NSMaxRange(beginRange)
            let innerBounds = NSRange(location: innerLocation, length: endRange.location - innerLocation)

            for pattern in pattern.subpatterns {
                if let results = resultsForPattern(pattern, line: line, bounds: innerBounds) {
                    resultSet.addResults(results)
                }
            }
            
            return resultSet
        }
        
        return nil
    }
    
    private func matchesForString(string: String, bounds: NSRange, pattern: String) -> [NSTextCheckingResult]? {
        let matches: [NSTextCheckingResult]
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: [])
            matches = expression.matchesInString(string, options: [], range: bounds)
        } catch let error {
            print("*** exception creating expresssion: \(error)")
            return nil
        }
        
        return matches
    }
    
    private func captureResultsForMatch(match: NSTextCheckingResult, captures: CaptureCollection) -> ResultSet? {
        var resultSet = ResultSet()
        
        for index in captures.captureIndexes {
            let range = match.rangeAtIndex(Int(index))
            if range.location == NSNotFound {
                continue
            }
            
            if let scope = captures[index]?.name {
                resultSet.addResult(Result(scope: scope, range: range))
            }
        }
        
        return resultSet.isEmpty ? nil : resultSet
    }
}
