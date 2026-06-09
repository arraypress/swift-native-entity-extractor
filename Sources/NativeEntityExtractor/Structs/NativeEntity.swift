//
//  NativeEntity.swift
//  NativeEntityExtractor
//
//  Created by David Sherlock on 9/25/25.
//

import Foundation

public struct NativeEntity {
    public let text: String
    public let type: NativeEntityType
    public let range: Range<String.Index>
    
    // NSDataDetector rich metadata
    public let date: Date?
    public let timeZone: TimeZone?
    public let duration: TimeInterval?
    public let url: URL?
    public let phoneNumber: String?
    public let addressComponents: [NSTextCheckingKey: String]?
    public let transitComponents: [NSTextCheckingKey: String]?
}
