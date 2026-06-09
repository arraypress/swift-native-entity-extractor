//
//  NativeEntityExtractor.swift
//  NativeEntityExtractor
//
//  Created by David Sherlock on 9/25/25.
//

import Foundation
import NaturalLanguage

public struct NativeEntityExtractor {
    
    // MARK: - NLTagger Methods
    
    /// Extract all NLTagger named entities
    public static func extractNamedEntities(
        from text: String,
        language: NLLanguage? = nil
    ) -> [NativeEntity] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        if let language = language {
            tagger.setLanguage(language, range: text.startIndex..<text.endIndex)
        }
        
        var results: [NativeEntity] = []
        
        let options: NLTagger.Options = [
            .omitWhitespace,
            .omitPunctuation,
            .joinNames
        ]
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: options
        ) { tag, range in
            guard let tag = tag else { return true }
            
            let entityType: NativeEntityType?
            switch tag {
            case .personalName:
                entityType = .personalName
            case .placeName:
                entityType = .placeName
            case .organizationName:
                entityType = .organizationName
            default:
                entityType = nil
            }
            
            if let entityType = entityType {
                let entity = NativeEntity(
                    text: String(text[range]),
                    type: entityType,
                    range: range,
                    date: nil,
                    timeZone: nil,
                    duration: nil,
                    url: nil,
                    phoneNumber: nil,
                    addressComponents: nil,
                    transitComponents: nil
                )
                results.append(entity)
            }
            
            return true
        }
        
        return results
    }
    
    /// Extract lexical classes (parts of speech)
    public static func extractLexicalClasses(
        from text: String
    ) -> [(text: String, type: NativeEntityType)] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        var results: [(String, NativeEntityType)] = []
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, range in
            if let tag = tag {
                let entityType: NativeEntityType?
                switch tag {
                case .noun: entityType = .noun
                case .verb: entityType = .verb
                case .adjective: entityType = .adjective
                case .adverb: entityType = .adverb
                case .pronoun: entityType = .pronoun
                case .determiner: entityType = .determiner
                case .particle: entityType = .particle
                case .preposition: entityType = .preposition
                case .number: entityType = .number
                case .conjunction: entityType = .conjunction
                case .interjection: entityType = .interjection
                case .classifier: entityType = .classifier
                case .idiom: entityType = .idiom
                case .otherWord: entityType = .otherWord
                default: entityType = nil
                }
                
                if let entityType = entityType {
                    results.append((String(text[range]), entityType))
                }
            }
            return true
        }
        
        return results
    }
    
    /// Get lemmas (base forms) of words
    public static func extractLemmas(from text: String) -> [(word: String, lemma: String)] {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        
        var results: [(String, String)] = []
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lemma,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, range in
            let word = String(text[range])
            let lemma = tag?.rawValue ?? word
            results.append((word, lemma))
            return true
        }
        
        return results
    }
    
    // MARK: - NSDataDetector Methods
    
    /// Extract all data detector entities
    public static func extractDataDetectorEntities(
        from text: String,
        types: NSTextCheckingResult.CheckingType = [.date, .link, .phoneNumber, .address, .transitInformation]
    ) -> [NativeEntity] {
        guard let detector = try? NSDataDetector(types: types.rawValue) else {
            return []
        }
        
        var results: [NativeEntity] = []
        let nsRange = NSRange(text.startIndex..., in: text)
        
        detector.enumerateMatches(in: text, options: [], range: nsRange) { match, _, _ in
            guard let match = match,
                  let range = Range(match.range, in: text) else { return }
            
            let matchedText = String(text[range])
            
            switch match.resultType {
            case .date:
                let entity = NativeEntity(
                    text: matchedText,
                    type: .date,
                    range: range,
                    date: match.date,
                    timeZone: match.timeZone,
                    duration: match.duration,
                    url: nil,
                    phoneNumber: nil,
                    addressComponents: nil,
                    transitComponents: nil
                )
                results.append(entity)
                
            case .link:
                let entity = NativeEntity(
                    text: matchedText,
                    type: .link,
                    range: range,
                    date: nil,
                    timeZone: nil,
                    duration: nil,
                    url: match.url,
                    phoneNumber: nil,
                    addressComponents: nil,
                    transitComponents: nil
                )
                results.append(entity)
                
            case .phoneNumber:
                let entity = NativeEntity(
                    text: matchedText,
                    type: .phoneNumber,
                    range: range,
                    date: nil,
                    timeZone: nil,
                    duration: nil,
                    url: nil,
                    phoneNumber: match.phoneNumber,
                    addressComponents: nil,
                    transitComponents: nil
                )
                results.append(entity)
                
            case .address:
                let entity = NativeEntity(
                    text: matchedText,
                    type: .address,
                    range: range,
                    date: nil,
                    timeZone: nil,
                    duration: nil,
                    url: nil,
                    phoneNumber: nil,
                    addressComponents: match.addressComponents,
                    transitComponents: nil
                )
                results.append(entity)
                
            case .transitInformation:
                let entity = NativeEntity(
                    text: matchedText,
                    type: .transitInformation,
                    range: range,
                    date: nil,
                    timeZone: nil,
                    duration: nil,
                    url: nil,
                    phoneNumber: nil,
                    addressComponents: nil,
                    transitComponents: match.components
                )
                results.append(entity)
                
            default:
                break
            }
        }
        
        return results
    }
    
    // MARK: - Language Detection
    
    /// Detect dominant language
    public static func detectLanguage(in text: String) -> NLLanguage? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage
    }
    
    /// Get language probabilities
    public static func languageHypotheses(
        for text: String,
        maxCount: Int = 3
    ) -> [(language: NLLanguage, probability: Double)] {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        let hypotheses = recognizer.languageHypotheses(withMaximum: maxCount)
        return hypotheses.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }
    
    // MARK: - Sentiment Analysis (iOS 13+)
    
    public static func analyzeSentiment(of text: String) -> (score: Double, sentiment: String) {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (tag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        let score = Double(tag?.rawValue ?? "0") ?? 0.0
        
        let sentiment: String
        if score < -0.5 {
            sentiment = "negative"
        } else if score > 0.5 {
            sentiment = "positive"
        } else {
            sentiment = "neutral"
        }
        
        return (score, sentiment)
    }
    
    // MARK: - Combined Extraction
    
    /// Extract ALL available entities and features
    public static func extractAllEntities(from text: String) -> [NativeEntity] {
        let namedEntities = extractNamedEntities(from: text)
        let dataDetectorEntities = extractDataDetectorEntities(from: text)
        
        return (namedEntities + dataDetectorEntities).sorted {
            $0.range.lowerBound < $1.range.lowerBound
        }
    }
    
}
