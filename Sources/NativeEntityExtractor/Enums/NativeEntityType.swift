//
//  NativeEntityType.swift
//  NativeEntityExtractor
//
//  Created by David Sherlock on 9/25/25.
//

import Foundation

public enum NativeEntityType: String, CaseIterable {
    // NLTagger entities (iOS 12+)
    case personalName
    case placeName
    case organizationName
    
    // NSDataDetector entities (iOS 4+)
    case date
    case link  // URLs and email addresses
    case phoneNumber
    case address  // Physical addresses with components
    case transitInformation  // Flight numbers, etc.
    
    // Linguistic features (not entities but available)
    case noun
    case verb
    case adjective
    case adverb
    case pronoun
    case determiner
    case particle
    case preposition
    case number
    case conjunction
    case interjection
    case classifier
    case idiom
    case otherWord
    case sentenceTerminator
    case openQuote
    case closeQuote
    case openParenthesis
    case closeParenthesis
    case wordJoiner
    case dash
    case otherPunctuation
    case whitespace
}
