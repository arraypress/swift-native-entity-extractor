# NativeEntityExtractor

A comprehensive Swift package for extracting named entities and linguistic features using Apple's native Natural Language framework (NLTagger) and NSDataDetector.

## Features

- 🏷 **Named Entity Recognition** - Extract people, places, and organizations
- 📅 **Data Detection** - Find dates, URLs, emails, phone numbers, and addresses
- 🌍 **Language Detection** - Identify languages with confidence scores
- 📝 **Linguistic Analysis** - Parts of speech, lemmatization
- 😊 **Sentiment Analysis** - Positive/negative/neutral classification (iOS 13+)
- 📍 **Address Parsing** - Extract street, city, state, ZIP components
- 🔗 **Zero Dependencies** - Uses only native iOS/macOS frameworks

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/NativeEntityExtractor.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter repository URL
3. Select version

## Usage

### Extract Named Entities

```swift
import NativeEntityExtractor

let text = "Tim Cook is the CEO of Apple in Cupertino."
let entities = text.namedEntities

for entity in entities {
    print("\(entity.text): \(entity.type)")
}
// Output:
// Tim Cook: personalName
// Apple: organizationName  
// Cupertino: placeName
```

### Detect Data Types

```swift
let text = "Call me at 555-0123 or email john@example.com. Meeting on Dec 31, 2024."
let dataEntities = text.dataDetectorEntities

for entity in dataEntities {
    switch entity.type {
    case .date:
        print("Date: \(entity.date!)")
    case .phoneNumber:
        print("Phone: \(entity.phoneNumber!)")
    case .link:
        if let email = entity.url?.absoluteString.replacingOccurrences(of: "mailto:", with: "") {
            print("Email: \(email)")
        }
    default:
        break
    }
}
```

### Extract Address Components

```swift
let text = "Apple Park, 1 Apple Park Way, Cupertino, CA 95014"
let entities = text.dataDetectorEntities

if let address = entities.first(where: { $0.type == .address }) {
    print("Street: \(address.addressStreet ?? "")")
    print("City: \(address.addressCity ?? "")")
    print("State: \(address.addressState ?? "")")
    print("ZIP: \(address.addressZIP ?? "")")
    print("Formatted: \(address.formattedAddress ?? "")")
}
```

### Language Detection

```swift
let text = "Bonjour le monde"
let language = text.detectedLanguage
print(language?.rawValue ?? "Unknown") // "fr"

// Get multiple language hypotheses with confidence
let hypotheses = NativeEntityExtractor.languageHypotheses(for: text, maxCount: 3)
for (lang, confidence) in hypotheses {
    print("\(lang.rawValue): \(confidence)")
}
```

### Parts of Speech

```swift
let text = "The quick brown fox jumps"
let parts = text.partsOfSpeech

for (word, type) in parts {
    print("\(word): \(type)")
}
// The: determiner
// quick: adjective
// brown: adjective  
// fox: noun
// jumps: verb
```

### Sentiment Analysis (iOS 13+)

```swift
if #available(iOS 13.0, *) {
    let text = "This is absolutely wonderful!"
    let (score, sentiment) = text.sentiment
    print("Sentiment: \(sentiment), Score: \(score)")
    // Sentiment: positive, Score: 0.8
}
```

### Lemmatization

```swift
let text = "The children were running quickly"
let lemmas = text.lemmas

for (word, lemma) in lemmas {
    print("\(word) → \(lemma)")
}
// children → child
// were → be
// running → run
```

## API Reference

### Entity Types

```swift
enum NativeEntityType {
    // Named entities (NLTagger)
    case personalName
    case placeName
    case organizationName
    
    // Data detection (NSDataDetector)
    case date
    case link  // URLs and emails
    case phoneNumber
    case address
    case transitInformation
    
    // Linguistic features
    case noun, verb, adjective, adverb
    case pronoun, determiner, particle
    // ... and more
}
```

### Main Functions

- `extractNamedEntities(from:language:)` - Extract people, places, organizations
- `extractDataDetectorEntities(from:types:)` - Extract dates, URLs, phones, addresses
- `extractLexicalClasses(from:)` - Get parts of speech
- `extractLemmas(from:)` - Get base forms of words
- `detectLanguage(in:)` - Identify language
- `analyzeSentiment(of:)` - Get sentiment score (iOS 13+)

### String Extensions

```swift
extension String {
    var entities: [NativeEntity]  // All entities
    var namedEntities: [NativeEntity]  // Names only
    var dataDetectorEntities: [NativeEntity]  // Data only
    var partsOfSpeech: [(String, NativeEntityType)]
    var lemmas: [(String, String)]
    var detectedLanguage: NLLanguage?
    var sentiment: (Double, String)  // iOS 13+
}
```

## What It Extracts

### From NLTagger
- Personal names
- Place names
- Organization names
- Parts of speech (noun, verb, adjective, etc.)
- Lemmas (base word forms)
- Language identification
- Sentiment scores

### From NSDataDetector
- Dates (with Date objects, timezone, duration)
- URLs
- Email addresses
- Phone numbers
- Physical addresses (with components)
- Transit information (flight numbers)

## Performance

- Native iOS/macOS implementation
- Optimized for on-device processing
- No network calls required
- Thread-safe

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create your feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License

## Author

Your Name

## Acknowledgments

Built with Apple's Natural Language framework and NSDataDetector.
