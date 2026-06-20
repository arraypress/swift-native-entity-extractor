//
//  NativeEntityType.swift
//  NativeEntityExtractor
//
//  Created by David Sherlock on 9/25/25.
//

import Foundation

/// The kinds of named entity that `NativeEntityExtractor` can extract.
///
/// These map to Apple's two entity-producing engines:
/// - `NLTagger` with the `.nameType` scheme (people, places, organizations).
/// - `NSDataDetector` (dates, links, phone numbers, addresses, transit info).
///
/// Parts of speech are *not* entities and are represented separately by
/// ``LexicalClass``.
public enum NativeEntityType: String, CaseIterable {
    // NLTagger name-type entities (iOS 12+ / macOS 10.14+)
    case personalName
    case placeName
    case organizationName

    // NSDataDetector entities (iOS 4+ / macOS 10.7+)
    case date
    case link  // URLs and email addresses (mailto:)
    case phoneNumber
    case address  // Physical addresses with components
    case transitInformation  // Flight numbers, etc.
}
