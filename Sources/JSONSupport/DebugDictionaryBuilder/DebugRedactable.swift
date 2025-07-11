//
//  DebugRedactable.swift
//  logging
//
//  Created by Robert Nash on 17/06/2025.
//

import Foundation

/// A protocol for types that produce structured debug output with optional redaction of sensitive fields.
///
/// Conforming types define which keys should be redacted and provide a dictionary representation
/// of their internal state suitable for debugging and logging.
///
/// - Important:
/// Implementations of `debugDictionary(redacting:)` must NOT access `debugDescription`
/// (directly or indirectly), as it leads to infinite recursion (if this happens, we break out of the loop for
/// you and print a log to the debugger).
public protocol DebugRedactable {
    
    /// A set of keys that should be redacted by default when generating debug output.
    static var redactedDebugKeys: Set<String> { get }

    /// Returns a dictionary representation of the value for debugging, redacting specified keys.
    ///
    /// - Parameter parentKeys: A set of parent keys to redact in addition to the type's own redacted keys.
    /// - Returns: A dictionary representation with sensitive values replaced where appropriate.
    func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any]
}

public extension DebugRedactable {
    
    /// Combines the type's own redacted keys with those inherited from parent contexts.
    ///
    /// - Parameter parentKeys: A set of redacted keys passed from higher in the hierarchy.
    /// - Returns: A merged set of keys to redact in the current context.
    func mergedRedactedKeys(_ parentKeys: Set<String>) -> Set<String> {
        return parentKeys.union(Self.redactedDebugKeys)
    }
}

public extension DebugRedactable {

    /// Applies redaction to a dictionary of key-value pairs according to the merged redaction keys.
    ///
    /// - Parameters:
    ///   - dictionary: The original dictionary containing potentially sensitive values.
    ///   - parentKeys: A set of parent keys that should also be redacted.
    /// - Returns: A dictionary with redacted values replaced with `"[REDACTED]"`.
    func redactedDebugDictionary(_ dictionary: [String: Any], including parentKeys: Set<String>) -> [String: Any] {
        let redactedKeys = Self.redactedDebugKeys.union(parentKeys)

        return dictionary.reduce(into: [String: Any]()) { result, pair in
            let (key, value) = pair

            if redactedKeys.contains(key) {
                result[key] = "[REDACTED]"
                return
            }

            switch value {
            case let nested as DebugRedactable:
                result[key] = nested.debugDictionary(redacting: redactedKeys)

            case let date as Date:
                let value = RedactableValue(date, format: .iso8601)
                    .debugDictionary(redacting: redactedKeys)[value_placeholder] as? String ?? "[invalid-date]"
                result[key] = value

            case let string as String:
                result[key] = string

            case let number as NSNumber:
                result[key] = number

            case let uuid as UUID:
                result[key] = uuid.uuidString

            case let data as Data:
                result[key] = "<\(data.count) bytes>"

            case is NSNull:
                result[key] = "null"

            case let dict as [String: Any]:
                result[key] = redactedDebugDictionary(dict, including: redactedKeys)

            case let array as [Any]:
                result[key] = array.map { element in
                    let raw: Any

                    if let nested = element as? DebugRedactable {
                        raw = nested.debugDictionary(redacting: redactedKeys)
                    } else if let date = element as? Date {
                        raw = RedactableValue(date, format: .iso8601)
                            .debugDictionary(redacting: redactedKeys)
                    } else if let uuid = element as? UUID {
                        raw = uuid.uuidString
                    } else if let string = element as? String {
                        raw = string
                    } else if let number = element as? NSNumber {
                        raw = number
                    } else {
                        raw = String(describing: element)
                    }

                    // Unwrap {"value": ...} dictionaries if possible
                    if let dict = raw as? [String: Any],
                       dict.count == 1, dict.keys.first == value_placeholder {
                        return dict[value_placeholder] ?? "[invalid]"
                    }

                    return raw
                }

            default:
                result[key] = String(describing: value)
            }
        }
    }
}

public extension DebugRedactable {

    /// Builds a redacted debug dictionary for a wrapped error,
    /// using its `DebugDescribable` output if available.
    ///
    /// - Parameters:
    ///   - label: A context label prefixing the error.
    ///   - error: The wrapped error value.
    ///   - parentKeys: Inherited redaction keys.
    /// - Returns: A dictionary containing a single `underlyingError` key.
    func redactedDebugDictionaryForError(
        label: String,
        error: Error,
        key: String = "underlyingError",
        redacting parentKeys: Set<String>
    ) -> [String: Any] {
        let merged = mergedRedactedKeys(parentKeys)

        if let describable = error as? DebugDescribable {
            return [key: describable.debugDictionary(redacting: merged)]
        } else {
            let description = String(reflecting: error)
            return [key: "\(label): \(description)"]
        }
    }
}
