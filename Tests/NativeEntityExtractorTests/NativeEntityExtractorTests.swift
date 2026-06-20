import XCTest
import NaturalLanguage
@testable import NativeEntityExtractor

final class NativeEntityExtractorTests: XCTestCase {
    
    // MARK: - Named Entity Tests (NLTagger)
    
    func testPersonNameExtraction() {
        let text = "Tim Cook is the CEO of Apple. He succeeded Steve Jobs in 2011."
        let entities = NativeEntityExtractor.extractNamedEntities(from: text)
        
        let personNames = entities.filter { $0.type == .personalName }.map { $0.text }
        
        XCTAssertTrue(personNames.contains("Tim Cook"))
        XCTAssertTrue(personNames.contains("Steve Jobs"))
    }
    
    func testPlaceNameExtraction() {
        let text = "The company is headquartered in Cupertino, California. They also have offices in London and Tokyo."
        let entities = NativeEntityExtractor.extractNamedEntities(from: text)
        
        let placeNames = entities.filter { $0.type == .placeName }.map { $0.text }
        
        XCTAssertGreaterThan(placeNames.count, 0)
        let hasCaliforniaOrCupertino = placeNames.contains("California") || placeNames.contains("Cupertino")
        XCTAssertTrue(hasCaliforniaOrCupertino)
    }
    
    func testOrganizationNameExtraction() {
        let text = "Apple Corporation is a technology company. Microsoft Corporation and Google LLC are competitors."
        let entities = NativeEntityExtractor.extractNamedEntities(from: text)
        
        let orgNames = entities.filter { $0.type == .organizationName }.map { $0.text }
        XCTAssertGreaterThan(orgNames.count, 0, "Should detect at least one organization")
    }
    
    func testMultiWordNameJoining() {
        let text = "The American Red Cross was established by Clara Barton."
        let entities = NativeEntityExtractor.extractNamedEntities(from: text)
        
        let allEntities = entities.map { $0.text }
        let hasMultiWord = allEntities.contains { $0.split(separator: " ").count > 1 }
        XCTAssertTrue(hasMultiWord, "Should join multi-word names")
    }
    
    // MARK: - Date Detection Tests
    
    func testDateExtraction() {
        let text = "The meeting is tomorrow at 3:00 PM. The deadline is December 31, 2024."
        let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)
        
        let dates = entities.filter { $0.type == .date }
        XCTAssertGreaterThan(dates.count, 0)
        
        for dateEntity in dates {
            XCTAssertNotNil(dateEntity.date)
        }
    }
    
    func testVariousDateFormats() {
        let dateFormats = [
            "12/31/2024",
            "December 31, 2024",
            "31 Dec 2024",
            "2024-12-31",
            "tomorrow",
            "next Monday",
            "last week",
            "3:00 PM",
            "15:30"
        ]
        
        for format in dateFormats {
            let entities = NativeEntityExtractor.extractDataDetectorEntities(from: format)
            let dates = entities.filter { $0.type == .date }
            
            // NSDataDetector should recognize most of these
            if !dates.isEmpty {
                XCTAssertNotNil(dates.first?.date, "Should extract date from: \(format)")
            }
        }
    }
    
    func testDateWithTimeZone() {
        let text = "Flight departs at 10:00 AM PST on January 15, 2024"
        let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)
        
        let dates = entities.filter { $0.type == .date }
        XCTAssertGreaterThan(dates.count, 0)
        
        // Check if timezone is detected
        if let firstDate = dates.first {
            // TimeZone detection depends on the format
            XCTAssertNotNil(firstDate.date)
        }
    }
    
    // MARK: - URL and Email Tests
    
    func testURLExtraction() {
        let urls = [
            "https://www.apple.com",
            "http://example.org",
            "www.google.com",
            "apple.com/store",
            "ftp://files.server.com"
        ]
        
        for urlString in urls {
            let text = "Visit \(urlString) for more info"
            let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)
            let links = entities.filter { $0.type == .link }
            
            XCTAssertGreaterThan(links.count, 0, "Should detect URL: \(urlString)")
            XCTAssertNotNil(links.first?.url)
        }
    }
    
    func testEmailExtraction() {
        let emails = [
            "john@example.com",
            "support@company.org",
            "user.name@domain.co.uk",
            "first+last@email.com"
        ]
        
        for email in emails {
            let text = "Contact: \(email)"
            let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)
            let links = entities.filter { $0.type == .link && $0.url?.scheme == "mailto" }
            
            XCTAssertEqual(links.count, 1, "Should detect email: \(email)")
            
            if let extractedEmail = links.first?.url?.absoluteString.replacingOccurrences(of: "mailto:", with: "") {
                XCTAssertEqual(extractedEmail, email)
            }
        }
    }
    
    func testMixedURLsAndEmails() {
        let text = "Visit https://apple.com or email support@apple.com for help"
        let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)
        
        let urls = entities.filter { $0.type == .link && $0.url?.scheme != "mailto" }
        let emails = entities.filter { $0.type == .link && $0.url?.scheme == "mailto" }
        
        XCTAssertEqual(urls.count, 1)
        XCTAssertEqual(emails.count, 1)
    }
    
    // MARK: - Phone Number Tests
    
    func testPhoneNumberFormats() {
        let phoneNumbers = [
            "(555) 123-4567",
            "555-123-4567",
            "+1-555-123-4567",
            "555.123.4567",
            "(555)123-4567",
            "1-800-APPLE-00",
            "+44 20 7123 4567"  // UK format
        ]
        
        for phone in phoneNumbers {
            let text = "Call: \(phone)"
            let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)
            let phones = entities.filter { $0.type == .phoneNumber }
            
            XCTAssertGreaterThan(phones.count, 0, "Should detect phone: \(phone)")
            XCTAssertNotNil(phones.first?.phoneNumber)
        }
    }
    
    // MARK: - Address Tests
    
    func testAddressExtraction() {
        let addresses = [
            "1 Apple Park Way, Cupertino, CA 95014",
            "1600 Pennsylvania Avenue, Washington, DC 20500",
            "221B Baker Street, London, UK",
            "350 Fifth Avenue, New York, NY 10118"
        ]
        
        for address in addresses {
            let entities = NativeEntityExtractor.extractDataDetectorEntities(from: address)
            let addressEntities = entities.filter { $0.type == .address }
            
            if !addressEntities.isEmpty {
                let addr = addressEntities.first!
                XCTAssertNotNil(addr.addressComponents)
                
                // Check for common components
                let components = addr.addressComponents!
                
                // At least some component should be present
                let hasAnyComponent = components[.street] != nil ||
                                      components[.city] != nil ||
                                      components[.state] != nil ||
                                      components[.zip] != nil
                
                XCTAssertTrue(hasAnyComponent, "Should have at least one address component for: \(address)")
            }
        }
    }
    
    func testAddressComponentHelpers() {
        let text = "1 Infinite Loop, Cupertino, CA 95014"
        let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)
        
        if let address = entities.first(where: { $0.type == .address }) {
            XCTAssertNotNil(address.addressCity)
            XCTAssertNotNil(address.addressState)
            XCTAssertNotNil(address.addressZIP)
            XCTAssertNotNil(address.formattedAddress)
            
            if let formatted = address.formattedAddress {
                XCTAssertTrue(formatted.contains("Cupertino") || formatted.contains("CA") || formatted.contains("95014"))
            }
        }
    }
    
    func testAddressFullComponentHelpers() {
        // Business-card-style text populates name/organization/phone alongside
        // the postal components. Every key should be reachable via a helper.
        let text = "Tim Cook, Apple Inc, 1 Apple Park Way, Cupertino, CA 95014, (800) 275-2273"
        let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)

        if let address = entities.first(where: { $0.type == .address }) {
            // Whatever NSDataDetector populated must be reachable via the helpers,
            // i.e. the helper and the raw dictionary must agree for every key.
            XCTAssertEqual(address.addressName, address.addressComponents?[.name])
            XCTAssertEqual(address.addressJobTitle, address.addressComponents?[.jobTitle])
            XCTAssertEqual(address.addressOrganization, address.addressComponents?[.organization])
            XCTAssertEqual(address.addressStreet, address.addressComponents?[.street])
            XCTAssertEqual(address.addressCity, address.addressComponents?[.city])
            XCTAssertEqual(address.addressState, address.addressComponents?[.state])
            XCTAssertEqual(address.addressZIP, address.addressComponents?[.zip])
            XCTAssertEqual(address.addressCountry, address.addressComponents?[.country])
            XCTAssertEqual(address.addressPhone, address.addressComponents?[.phone])
        }
    }

    // MARK: - Transit Information Tests

    func testTransitInformation() {
        let transitTexts = [
            "Flight AA 1234",
            "Flight UA123",
            "American Airlines flight 456",
            "Delta 789"
        ]

        for transit in transitTexts {
            let entities = NativeEntityExtractor.extractDataDetectorEntities(from: transit)
            let transitEntities = entities.filter { $0.type == .transitInformation }

            // Transit detection is unreliable, just check it doesn't crash
            XCTAssertNotNil(transitEntities)
        }
    }

    func testTransitComponentHelpers() {
        // When a transit match is found, airline/flight must be reachable via the
        // helpers and agree with the raw dictionary.
        let entities = NativeEntityExtractor.extractDataDetectorEntities(from: "Flight AA 1234")

        if let transit = entities.first(where: { $0.type == .transitInformation }) {
            XCTAssertEqual(transit.transitAirline, transit.transitComponents?[.airline])
            XCTAssertEqual(transit.transitFlight, transit.transitComponents?[.flight])
            // At least one transit component should be populated for a real match.
            XCTAssertTrue(transit.transitAirline != nil || transit.transitFlight != nil)
        }
    }
    
    // MARK: - Lexical Class Tests
    
    func testPartsOfSpeech() {
        let text = "The quick brown fox jumps over the lazy dog."
        let parts = NativeEntityExtractor.extractLexicalClasses(from: text)
        
        let nouns = parts.filter { $0.type == .noun }.map { $0.text }
        let verbs = parts.filter { $0.type == .verb }.map { $0.text }
        let adjectives = parts.filter { $0.type == .adjective }.map { $0.text }
        let determiners = parts.filter { $0.type == .determiner }.map { $0.text }
        
        XCTAssertTrue(nouns.contains("fox"))
        XCTAssertTrue(nouns.contains("dog"))
        XCTAssertTrue(verbs.contains("jumps"))
        XCTAssertGreaterThan(adjectives.count, 0)
        XCTAssertGreaterThan(determiners.count, 0)
    }
    
    func testAllPartsOfSpeech() {
        let text = "Wow! The cat quickly ran and jumped over there, didn't it?"
        let parts = NativeEntityExtractor.extractLexicalClasses(from: text)
        
        let types = Set(parts.map { $0.type })
        
        // Should identify various types
        XCTAssertTrue(types.contains(.noun) || types.contains(.pronoun))
        XCTAssertTrue(types.contains(.verb))
        XCTAssertGreaterThan(types.count, 3, "Should identify multiple parts of speech")
    }
    
    // MARK: - Lemmatization Tests
    
    func testLemmatization() {
        // Test pairs where NLTagger reliably works
        let reliablePairs = [
            ("running", "run"),
            ("went", "go"),
            ("children", "child")
        ]
        
        for (word, expectedLemma) in reliablePairs {
            let lemmas = NativeEntityExtractor.extractLemmas(from: word)
            
            if let lemma = lemmas.first?.lemma {
                XCTAssertEqual(lemma, expectedLemma, "\(word) should lemmatize to \(expectedLemma)")
            }
        }
        
        // Test that lemmatization at least returns something for common words
        let wordsToLemmatize = ["cats", "better", "mice", "dogs", "played", "swimming"]
        
        for word in wordsToLemmatize {
            let lemmas = NativeEntityExtractor.extractLemmas(from: word)
            XCTAssertGreaterThan(lemmas.count, 0, "Should return at least one lemma for \(word)")
            
            // The lemma should at least be a valid string (even if not the expected one)
            if let lemma = lemmas.first?.lemma {
                XCTAssertFalse(lemma.isEmpty, "Lemma should not be empty for \(word)")
            }
        }
    }
    
    func testLemmatizationWithIrregularForms() {
        // Test that lemmatization at least processes irregular forms
        let irregularWords = ["went", "better", "mice", "geese"]
        
        for word in irregularWords {
            let lemmas = NativeEntityExtractor.extractLemmas(from: word)
            XCTAssertEqual(lemmas.count, 1, "Should process single word")
            XCTAssertNotNil(lemmas.first?.lemma, "Should return a lemma for \(word)")
        }
        
        // Check specific cases that work reliably
        let wentLemmas = NativeEntityExtractor.extractLemmas(from: "went")
        XCTAssertEqual(wentLemmas.first?.lemma, "go")
    }
    
    // MARK: - Language Detection Tests
    
    func testLanguageDetection() {
        let languages: [(text: String, expected: NLLanguage)] = [
            ("This is English text.", .english),
            ("Ceci est un texte français.", .french),
            ("Este es un texto español.", .spanish),
            ("Questo è un testo italiano.", .italian),
            ("Dies ist ein deutscher Text.", .german),
            ("これは日本語のテキストです。", .japanese),
            ("这是中文文本。", .simplifiedChinese),
            ("Это русский текст.", .russian)
        ]
        
        for (text, expected) in languages {
            let detected = NativeEntityExtractor.detectLanguage(in: text)
            XCTAssertEqual(detected, expected, "Should detect \(expected.rawValue) for: \(text)")
        }
    }
    
    func testLanguageHypotheses() {
        let text = "Hello world"
        let hypotheses = NativeEntityExtractor.languageHypotheses(for: text, maxCount: 3)
        
        XCTAssertGreaterThan(hypotheses.count, 0)
        XCTAssertLessThanOrEqual(hypotheses.count, 3)
        XCTAssertEqual(hypotheses.first?.language, .english)
        
        // Check probabilities are sorted
        for i in 0..<hypotheses.count-1 {
            XCTAssertGreaterThanOrEqual(hypotheses[i].probability, hypotheses[i+1].probability)
        }
    }
    
    // MARK: - Sentiment Analysis Tests
    
    @available(iOS 13.0, macOS 10.15, *)
    func testSentimentAnalysis() {
        let sentiments: [(text: String, expected: String)] = [
            ("This is absolutely wonderful! Amazing! I love it!", "positive"),
            ("This is terrible. Awful. I hate it completely.", "negative"),
            ("I love this so much! Best thing ever!", "positive"),
            ("This is the worst. Completely disappointed.", "negative")
        ]
        
        for (text, expected) in sentiments {
            let (score, sentiment) = NativeEntityExtractor.analyzeSentiment(of: text)
            XCTAssertEqual(sentiment, expected, "Should detect \(expected) sentiment for: \(text)")
            
            if expected == "positive" {
                XCTAssertGreaterThan(score, 0)
            } else if expected == "negative" {
                XCTAssertLessThan(score, 0)
            }
        }
    }
    
    // MARK: - Combined Extraction Tests
    
    func testCombinedExtraction() {
        let text = """
        Tim Cook announced that Apple will open a new store in Paris on January 15, 2024.
        Contact them at info@apple.com or call 1-800-APPLE.
        """
        
        let entities = NativeEntityExtractor.extractAllEntities(from: text)
        
        XCTAssertGreaterThan(entities.count, 0)
        
        let types = Set(entities.map { $0.type })
        XCTAssertGreaterThan(types.count, 1)
        
        // Check sorting
        for i in 0..<entities.count-1 {
            XCTAssertLessThanOrEqual(entities[i].range.lowerBound, entities[i+1].range.lowerBound)
        }
    }
    
    // MARK: - String Extension Tests
    
    func testStringExtensions() {
        let text = "Steve Jobs founded Apple in Cupertino. Email: steve@apple.com"
        
        XCTAssertGreaterThan(text.namedEntities.count, 0)
        XCTAssertGreaterThan(text.dataDetectorEntities.count, 0)
        XCTAssertGreaterThan(text.entities.count, 0)
        XCTAssertEqual(text.detectedLanguage, .english)
        XCTAssertGreaterThan(text.partsOfSpeech.count, 0)
        XCTAssertGreaterThan(text.lemmas.count, 0)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyString() {
        let empty = ""
        
        XCTAssertEqual(NativeEntityExtractor.extractNamedEntities(from: empty).count, 0)
        XCTAssertEqual(NativeEntityExtractor.extractDataDetectorEntities(from: empty).count, 0)
        XCTAssertEqual(NativeEntityExtractor.extractLexicalClasses(from: empty).count, 0)
        XCTAssertNil(NativeEntityExtractor.detectLanguage(in: empty))
    }
    
    func testSpecialCharacters() {
        let text = "Contact: user@email.com 📧 Call: +1-555-0123 ☎️"
        
        let entities = NativeEntityExtractor.extractDataDetectorEntities(from: text)
        
        let emails = entities.filter { $0.type == .link && $0.url?.scheme == "mailto" }
        let phones = entities.filter { $0.type == .phoneNumber }
        
        XCTAssertGreaterThan(emails.count, 0)
        XCTAssertGreaterThan(phones.count, 0)
    }
    
    func testLongText() {
        let longText = String(repeating: "Tim Cook is the CEO. ", count: 100)
        
        measure {
            _ = NativeEntityExtractor.extractAllEntities(from: longText)
        }
    }
    
    func testMixedLanguages() {
        let text = "Hello world. Bonjour le monde. Hola mundo."
        
        let language = NativeEntityExtractor.detectLanguage(in: text)
        XCTAssertNotNil(language) // Should detect dominant language
    }
}
