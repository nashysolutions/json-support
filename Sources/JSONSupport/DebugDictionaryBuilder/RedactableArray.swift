//
//  RedactableArray.swift
//  json-support
//
//  Created by Robert Nash on 17/06/2025.
//

import Foundation

import Foundation

/// A type-erased array wrapper that supports redacted debug output.
public struct RedactableArray: DebugRedactable {
    
    /// The underlying elements stored in the array.
    ///
    /// Elements can be of any type. If they conform to `DebugRedactable`, they are formatted recursively.
    public let elements: [Any]

    /// Creates a new `RedactableArray` from a generic array of values.
    ///
    /// - Parameter elements: The values to store and debug-format.
    public init(_ elements: [Any]) {
        self.elements = elements
    }

    /// The set of default keys to redact. `RedactableArray` itself does not redact any keys.
    public static var redactedDebugKeys: Set<String> { [] }

    /// Returns a debug-formatted dictionary representation of the array,
    /// applying redaction to any nested `DebugRedactable` values.
    ///
    /// - Parameter parentKeys: A set of redacted keys from the parent context.
    /// - Returns: A dictionary with a single key `"values"` containing the formatted array.
    public func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
        let formatted = elements.map { element in
            if let redactable = element as? DebugRedactable {
                return redactable.debugDictionary(redacting: parentKeys)
            } else {
                return RedactableValue(element).debugDictionary(redacting: parentKeys)
            }
        }

        return ["values": formatted]
    }
}

public extension RedactableArray {
    
    /// Convenience initializer for an array of known `DebugRedactable` values.
    ///
    /// - Parameter elements: The redactable values to wrap.
    init(_ elements: [DebugRedactable]) {
        self.elements = elements
    }
}
