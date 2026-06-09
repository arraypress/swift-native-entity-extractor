//
//  NativeEntity+Extension.swift
//  NativeEntityExtractor
//
//  Created by David Sherlock on 9/25/25.
//

import Foundation

public extension NativeEntity {
    
    /// Helper to access address components safely
    var addressStreet: String? {
        addressComponents?[.street]
    }
    
    var addressCity: String? {
        addressComponents?[.city]
    }
    
    var addressState: String? {
        addressComponents?[.state]
    }
    
    var addressZIP: String? {
        addressComponents?[.zip]
    }
    
    var addressCountry: String? {
        addressComponents?[.country]
    }
    
    /// Get formatted address string
    var formattedAddress: String? {
        guard let components = addressComponents else { return nil }
        
        var parts: [String] = []
        
        if let street = components[.street] {
            parts.append(street)
        }
        if let city = components[.city] {
            parts.append(city)
        }
        if let state = components[.state] {
            parts.append(state)
        }
        if let zip = components[.zip] {
            parts.append(zip)
        }
        if let country = components[.country] {
            parts.append(country)
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
    
}
