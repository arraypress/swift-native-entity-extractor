//
//  LexicalClass.swift
//  NativeEntityExtractor
//
//  Created by David Sherlock on 9/25/25.
//

import Foundation

/// A part of speech produced by `NLTagger` with the `.lexicalClass` scheme.
///
/// These are the word-level lexical classes returned by
/// ``NativeEntityExtractor/extractLexicalClasses(from:)``. Apple's lexical-class
/// scheme also defines punctuation and whitespace sub-classes, but those are
/// intentionally omitted here — this library is an *entity* extractor and only
/// surfaces the word classes that carry linguistic meaning.
public enum LexicalClass: String, CaseIterable {
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
}
