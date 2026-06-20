import Foundation
import NaturalLanguage

public extension String {
    
    /// Extract all entities
    var entities: [NativeEntity] {
        NativeEntityExtractor.extractAllEntities(from: self)
    }
    
    /// Extract named entities (people, places, organizations)
    var namedEntities: [NativeEntity] {
        NativeEntityExtractor.extractNamedEntities(from: self)
    }
    
    /// Extract data detector entities (dates, links, phones, addresses)
    var dataDetectorEntities: [NativeEntity] {
        NativeEntityExtractor.extractDataDetectorEntities(from: self)
    }
    
    /// Parts of speech
    var partsOfSpeech: [(text: String, type: LexicalClass)] {
        NativeEntityExtractor.extractLexicalClasses(from: self)
    }
    
    /// Get lemmas
    var lemmas: [(word: String, lemma: String)] {
        NativeEntityExtractor.extractLemmas(from: self)
    }
    
    /// Detected language
    var detectedLanguage: NLLanguage? {
        NativeEntityExtractor.detectLanguage(in: self)
    }
    
    /// Sentiment score
    var sentiment: (score: Double, sentiment: String) {
        NativeEntityExtractor.analyzeSentiment(of: self)
    }
    
}
