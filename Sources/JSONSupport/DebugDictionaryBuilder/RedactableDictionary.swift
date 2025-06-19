//
//  RedactableDictionary.swift
//  json-support
//
//  Created by Robert Nash on 17/06/2025.
//

import Foundation

/// A wrapper around a dictionary of values that conforms to `DebugRedactable`,
/// allowing for structured and optionally redacted debug output.
public struct RedactableDictionary: DebugRedactable {
    
    /// The underlying dictionary of values to be rendered for debugging.
    public let dictionary: [String: Any]

    /// A set of keys that should be redacted by default.
    ///
    /// - Note: This implementation performs no redaction by default.
    public static var redactedDebugKeys: Set<String> { [] }

    /// Creates a new redactable dictionary wrapper.
    ///
    /// - Parameter dictionary: The dictionary of values to represent for debugging.
    public init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    /// Returns a debug dictionary representation, recursively formatting nested values.
    ///
    /// If a value conforms to `DebugRedactable`, its `debugDictionary(redacting:)` method is used.
    /// All other values are wrapped in `RedactableValue` to provide consistent formatting.
    ///
    /// - Parameter parentKeys: A set of keys to redact, inherited from parent contexts.
    /// - Returns: A dictionary suitable for debug output.
    public func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
        dictionary.reduce(into: [String: Any]()) { result, pair in
            let (key, value) = pair

            if let nested = value as? DebugRedactable {
                result[key] = nested.debugDictionary(redacting: parentKeys)
            } else {
                result[key] = RedactableValue(value).debugDictionary(redacting: parentKeys)
            }
        }
    }
}
