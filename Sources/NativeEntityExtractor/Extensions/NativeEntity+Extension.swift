//
//  NativeEntity+Extension.swift
//  NativeEntityExtractor
//
//  Created by David Sherlock on 9/25/25.
//

import Foundation

public extension NativeEntity {

    // MARK: - Address Components
    //
    // Convenience accessors for every key NSDataDetector populates on an address
    // match. The raw dictionary is always available via `addressComponents`.

    var addressName: String? {
        addressComponents?[.name]
    }

    var addressJobTitle: String? {
        addressComponents?[.jobTitle]
    }

    var addressOrganization: String? {
        addressComponents?[.organization]
    }

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

    var addressPhone: String? {
        addressComponents?[.phone]
    }

    // MARK: - Transit Components
    //
    // Convenience accessors for transit (e.g. flight) matches. The raw dictionary
    // is always available via `transitComponents`.

    var transitAirline: String? {
        transitComponents?[.airline]
    }

    var transitFlight: String? {
        transitComponents?[.flight]
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
