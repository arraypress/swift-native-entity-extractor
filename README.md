# Swift Native Entity Extractor

Extract named entities and linguistic features from text using Apple's native frameworks — `NLTagger` (Natural Language) and `NSDataDetector`. No network calls, no third-party models: people, places, organizations, dates, links, phone numbers, and addresses are recognized entirely on-device through ergonomic `String` extensions.

## Features

- 🎯 **Named entities** — detects personal names, place names, and organization names via `NLTagger`
- 📅 **Data detection** — dates, links (URLs/emails), phone numbers, addresses, and transit info via `NSDataDetector`
- 🏠 **Address components** — structured street/city/state/ZIP/country accessors plus a `formattedAddress` helper
- 🔤 **Parts of speech** — nouns, verbs, adjectives, adverbs, and more lexical classes
- 🌱 **Lemmatization** — base-form (lemma) for each word
- 🌍 **Language detection** — dominant language plus ranked language hypotheses
- 😊 **Sentiment analysis** — paragraph sentiment score with a negative/neutral/positive label
- 🧩 **String extensions** — `entities`, `namedEntities`, `dataDetectorEntities`, `partsOfSpeech`, `lemmas`, `detectedLanguage`, `sentiment`
- 🛠️ **Static API** — call `NativeEntityExtractor` methods directly for fine-grained control
- 🧱 **Rich entity model** — `NativeEntity` carries text, type, range, and type-specific metadata (date, URL, phone, address)
- 🔒 **On-device & private** — no network, no API keys, built on Apple frameworks
- 📦 **Zero dependencies** — pure Foundation + NaturalLanguage

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-native-entity-extractor.git", from: "1.0.0")
]
```

## Usage

### String extensions

```swift
import NativeEntityExtractor

let text = "Tim Cook visited Paris on March 15th. Call +1-555-0100 or apple.com."

// All entities (named + data-detector), sorted by position
for entity in text.entities {
    print("\(entity.type): \(entity.text)")
}

// Just named entities
let people = text.namedEntities.filter { $0.type == .personalName }

// Just data-detector entities
for entity in text.dataDetectorEntities {
    print("\(entity.type): \(entity.text)")
}
```

### Linguistic features

```swift
let text = "The quick brown foxes were running."

for (word, type) in text.partsOfSpeech {
    print("\(word): \(type)")          // foxes: noun, running: verb, ...
}

for (word, lemma) in text.lemmas {
    print("\(word) -> \(lemma)")        // foxes -> fox, running -> run
}

text.detectedLanguage                   // Optional(NLLanguage.english)

let result = text.sentiment
print("\(result.sentiment) (\(result.score))")  // "neutral (0.0)"
```

### Addresses

```swift
let text = "Send it to 1 Infinite Loop, Cupertino, CA 95014."

if let address = text.dataDetectorEntities.first(where: { $0.type == .address }) {
    print(address.addressStreet ?? "")   // "1 Infinite Loop"
    print(address.addressCity ?? "")     // "Cupertino"
    print(address.addressState ?? "")    // "CA"
    print(address.addressZIP ?? "")      // "95014"
    print(address.formattedAddress ?? "")
}
```

Every component `NSDataDetector` can populate is reachable via a helper —
`addressName`, `addressJobTitle`, `addressOrganization`, `addressStreet`,
`addressCity`, `addressState`, `addressZIP`, `addressCountry`, `addressPhone` —
or via the raw `addressComponents` dictionary. Transit matches expose
`transitAirline` / `transitFlight` (and the raw `transitComponents`).

### Static API

```swift
let named   = NativeEntityExtractor.extractNamedEntities(from: text)
let data    = NativeEntityExtractor.extractDataDetectorEntities(from: text)
let all     = NativeEntityExtractor.extractAllEntities(from: text)
let pos     = NativeEntityExtractor.extractLexicalClasses(from: text)
let lemmas  = NativeEntityExtractor.extractLemmas(from: text)
let lang    = NativeEntityExtractor.detectLanguage(in: text)
let hyps    = NativeEntityExtractor.languageHypotheses(for: text, maxCount: 3)
let mood    = NativeEntityExtractor.analyzeSentiment(of: text)

// Restrict data-detector types
let links = NativeEntityExtractor.extractDataDetectorEntities(from: text, types: [.link])
```

## How It Works

Named entities and parts of speech come from `NLTagger` (the `.nameType`, `.lexicalClass`, and `.lemma` schemes). Dates, links, phone numbers, addresses, and transit information come from `NSDataDetector`. Language detection uses `NLLanguageRecognizer`, and sentiment uses `NLTagger`'s `.sentimentScore` scheme. `extractAllEntities` merges named and data-detector entities and sorts them by their position in the source text.

## Models

| Type | Description |
|------|-------------|
| `NativeEntity` | `text`, `type`, `range`, plus optional `date`, `timeZone`, `duration`, `url`, `phoneNumber`, `addressComponents`, `transitComponents`; address helpers `addressName` / `addressJobTitle` / `addressOrganization` / `addressStreet` / `addressCity` / `addressState` / `addressZIP` / `addressCountry` / `addressPhone` / `formattedAddress`; transit helpers `transitAirline` / `transitFlight` |
| `NativeEntityType` | The entity kinds only: named (`personalName`, `placeName`, `organizationName`) and data-detector (`date`, `link`, `phoneNumber`, `address`, `transitInformation`) |
| `LexicalClass` | Parts of speech returned by `extractLexicalClasses` / `partsOfSpeech` (`noun`, `verb`, `adjective`, `adverb`, `pronoun`, `determiner`, …) — kept separate from entities |
| `NLTagSchemeType` | Enumerates the available `NLTagger` schemes (token type, lexical class, name type, lemma, language, script, sentiment) |

## Use Cases

- Highlighting people, places, and organizations in user text
- Extracting structured contact info (phones, addresses, links) from messages
- On-device language detection and routing
- Lightweight sentiment scoring for reviews or feedback

## Testing

```bash
swift test
```

Tests cover named-entity extraction, data detection, linguistic features, and address parsing.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
