//
//  DebugDictionaryBuilder.swift
//  json-support
//
//  Created by Robert Nash on 17/05/2025.
//

import Foundation

/// A builder that generates pretty-printed JSON descriptions from `[String: Any]` dictionaries,
/// optionally redacting values based on specified key content.
///
/// This utility is intended for diagnostic or debugging output where
/// sensitive keys or values may need to be redacted.
///
/// Values conforming to `DebugRedactable` will respect custom redaction rules.
/// Other values are flattened and converted using fallback sanitisation.
public struct DebugDictionaryBuilder {
    
    /// A set of key fragments whose matching values should be redacted.
    ///
    /// If a key contains any of these fragments (case-insensitive),
    /// its associated value will be replaced with `[REDACTED]`.
    public var redactKeys: Set<String>

    /// Creates a new `DebugDictionaryBuilder`.
    ///
    /// - Parameter redactKeys: A set of string fragments to match against keys for redaction.
    public init(redactKeys: Set<String> = []) {
        self.redactKeys = redactKeys
    }

    /// Builds a dictionary of `Redactable` values from a `[String: Any]` input dictionary.
    ///
    /// Values that already conform to `DebugRedactable` are preserved.
    /// Other values are wrapped in `Redactable.value(...)`.
    ///
    /// - Parameter dictionary: The input dictionary.
    /// - Returns: A dictionary of `Redactable` values keyed by the same keys.
    public func makeRedactables(from dictionary: [String: Any]) -> [String: Redactable] {
        dictionary.mapValues { value in
            if let redactable = value as? DebugRedactable {
                return Redactable(any: redactable)
            } else {
                return .value(value)
            }
        }
    }

    /// Returns a flat, compact JSON description of the input dictionary.
    ///
    /// Redaction is applied to keys matching any of `redactKeys`.
    ///
    /// - Parameter dictionary: The dictionary to describe.
    /// - Returns: A compact JSON string or fallback description.
    public func flatCompactDescription(from dictionary: [String: Any]) -> String {
        let redactables = makeRedactables(from: dictionary)
        let flat = redactables.mapValues { $0.normalised(redacting: redactKeys) }

        if let data = try? JSONSerialization.data(withJSONObject: flat, options: []),
           let string = String(data: data, encoding: .utf8) {
            return string
        }

        return String(describing: flat)
    }

    /// Returns a pretty-printed JSON string representing the input dictionary.
    ///
    /// Redacts sensitive fields based on key matches and sanitises unsupported types.
    ///
    /// - Parameter dictionary: The dictionary to format.
    /// - Returns: A pretty-printed JSON string with redaction applied.
    public func makeDescription(from dictionary: [String: Any]) -> String {
        let flattened = dictionary.mapValues { value in
            if let redactable = value as? DebugRedactable {
                return Redactable(any: redactable).normalised(redacting: redactKeys)
            } else {
                return fallbackSanitiseValue(value)
            }
        }

        if let data = try? JSONSerialization.data(withJSONObject: flattened, options: [.prettyPrinted]),
           var json = String(data: data, encoding: .utf8) {
            json = json.replacingOccurrences(of: "\\/", with: "/")
            return json
        }

        return String(describing: flattened)
    }

    // MARK: - Internal Helpers

    /// Sanitises a dictionary recursively, redacting any sensitive values.
    private func sanitise(_ dictionary: [String: Any]) -> [String: Any] {
        dictionary.mapValues { normaliseOrSanitise($0) }
    }

    /// Handles fallback formatting for unsupported values, including basic redaction.
    private func fallbackSanitiseValue(_ value: Any) -> Any {
        switch value {
        case let string as String:
            if shouldRedact(value: string) {
                return [
                    value_placeholder: "[REDACTED]",
                    "type": "String",
                    "isNilOrEmpty": string.isEmpty
                ]
            } else {
                return string
            }

        case let int as Int:
            return shouldRedact(value: String(int))
                ? [value_placeholder: "[REDACTED]", "type": "Int"]
                : int

        case let double as Double:
            return shouldRedact(value: String(double))
                ? [value_placeholder: "[REDACTED]", "type": "Double"]
                : double

        case let bool as Bool:
            return shouldRedact(value: String(bool))
                ? [value_placeholder: "[REDACTED]", "type": "Bool"]
                : bool

        case _ as NSNull:
            return [value_placeholder: "[REDACTED]", "type": "Null", "isNilOrEmpty": true]

        case let date as Date:
            return Self.dateFormatter.string(from: date)

        case let dict as [String: Any]:
            return sanitise(dict)

        case let array as [Any]:
            return array.map { fallbackSanitiseValue($0) }

        default:
            let description = String(describing: value)
            let typeName = String(describing: type(of: value))
            return shouldRedact(value: description)
                ? [value_placeholder: "[REDACTED]", "type": typeName]
                : description
        }
    }

    /// Converts a value using `DebugRedactable` if supported, otherwise falls back to sanitisation.
    private func normaliseOrSanitise(_ value: Any) -> Any {
        if let redactable = value as? DebugRedactable {
            return Redactable(any: redactable).normalised(redacting: redactKeys)
        } else {
            return fallbackSanitiseValue(value)
        }
    }

    /// Determines whether a given value string should be redacted based on the `redactKeys`.
    ///
    /// - Parameter value: The value string to check.
    /// - Returns: `true` if the value should be redacted.
    private func shouldRedact(value: String) -> Bool {
        let lowercased = value.lowercased()
        return redactKeys.contains { lowercased.contains($0.lowercased()) }
    }

    /// A shared date formatter used for displaying `Date` values consistently.
    ///
    /// Uses medium styles for both date and time and respects system locale/time zone.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter
    }()
}
