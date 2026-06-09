//
//  NLTagSchemeType.swift
//  NativeEntityExtractor
//
//  Created by David Sherlock on 9/25/25.
//

import Foundation

public enum NLTagSchemeType {
    // Available tag schemes for NLTagger
    case tokenType                  // .word, .punctuation, .whitespace, .other
    case lexicalClass               // .noun, .verb, .adjective, .adverb, etc.
    case nameType                   // .personalName, .placeName, .organizationName
    case nameTypeOrLexicalClass     // Combined
    case lemma                      // Base form of words
    case language                   // Language identification
    case script                     // Script identification (Latin, Arabic, etc.)
    case sentimentScore             // Sentiment analysis (iOS 13+)
}
