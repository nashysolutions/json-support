//
//  DebugDescribable.swift
//  json-support
//
//  Created by Robert Nash on 17/06/2025.
//

import Foundation

/// A protocol that combines `DebugRedactable` and `CustomDebugStringConvertible`,
/// enabling types to produce redacted, human-readable debug descriptions.
///
/// Types conforming to `DebugDescribable` must implement `debugDictionary(redacting:)`,
/// and will automatically gain a default `debugDescription` using pretty-printed JSON.
public protocol DebugDescribable: DebugRedactable, CustomDebugStringConvertible {}

public extension DebugDescribable {
    
    /// A pretty-printed JSON string representing the debug state of the instance.
    ///
    /// Redaction is automatically applied based on the type’s `redactedDebugKeys`.
    ///
    /// This implementation uses `DebugDictionaryBuilder` for formatting.
    var debugDescription: String {
        let dict = debugDictionary(redacting: Self.redactedDebugKeys)
        return DebugDictionaryBuilder().makeDescription(from: dict)
    }
}
