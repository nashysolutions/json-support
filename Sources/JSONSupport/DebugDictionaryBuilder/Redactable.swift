//
//  Redactable.swift
//  json-support
//
//  Created by Robert Nash on 17/06/2025.
//

import Foundation

/// A flexible wrapper for redacted debug output, supporting values, arrays, and dictionaries.
///
/// `Redactable` provides tools for formatting and redacting debug output,
/// including flattening into human-readable or JSON-compatible structures.
public enum Redactable: DebugRedactable {
    
    /// A single value, optionally formatted using a date style.
    case value(Any, RedactableDateFormatStyle = .default)

    /// An array of arbitrary elements.
    case array([Any])

    /// A dictionary of values keyed by strings.
    case dictionary([String: Any])

    /// Keys to be redacted by default. `Redactable` has no intrinsic redacted keys.
    public static var redactedDebugKeys: Set<String> { [] }

    /// Produces a redacted dictionary suitable for debug output.
    ///
    /// - Parameter parentKeys: Keys inherited from the calling context to redact.
    /// - Returns: A debug-friendly dictionary representation.
    public func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
        switch self {
        case let .value(value, format):
            return RedactableValue(value, format: format).debugDictionary(redacting: parentKeys)

        case let .array(elements):
            let values = elements.map {
                if let redactable = $0 as? DebugRedactable {
                    return redactable.debugDictionary(redacting: parentKeys)
                } else {
                    return Redactable.value($0).debugDictionary(redacting: parentKeys)
                }
            }
            return ["values": values]

        case let .dictionary(dict):
            let values = dict.reduce(into: [String: Any]()) { result, pair in
                let (key, value) = pair
                if let redactable = value as? DebugRedactable {
                    result[key] = redactable.debugDictionary(redacting: parentKeys)
                } else {
                    result[key] = Redactable.value(value).debugDictionary(redacting: parentKeys)
                }
            }
            return values
        }
    }
}

public extension Redactable {
    
    /// Normalises the current value into a simplified form.
    ///
    /// This is useful for serialization or rendering human-friendly descriptions.
    ///
    /// - Parameter parentKeys: Redacted keys from upstream context.
    /// - Returns: A value suitable for display or encoding.
    func normalised(redacting parentKeys: Set<String> = []) -> Any {
        switch self {
        case let .value(value, format):
            let unwrapped = unwrap(value)
            return formatValue(unwrapped, with: format)

        case let .array(elements):
            return elements.map { Redactable(any: $0).normalised(redacting: parentKeys) }

        case let .dictionary(dict):
            return dict.reduce(into: [String: Any]()) { result, pair in
                let (key, value) = pair
                result[key] = Redactable(any: value).normalised(redacting: parentKeys)
            }
        }
    }

    /// Unwraps an optional value to its contained value or returns `"nil"`.
    private func unwrap(_ any: Any) -> Any {
        let mirror = Mirror(reflecting: any)
        return mirror.displayStyle == .optional
            ? mirror.children.first?.value ?? "nil"
            : any
    }

    /// Formats a value according to a date format style, if applicable.
    private func formatValue(_ value: Any, with format: RedactableDateFormatStyle) -> Any {
        switch format {
        case .default:
            return value
        case .iso8601:
            if let date = value as? Date {
                return ISO8601DateFormatter().string(from: date)
            }
            return value
        case .shortDate:
            if let date = value as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter.string(from: date)
            }
            return value
        case .timeOnly:
            if let date = value as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter.string(from: date)
            }
            return value
        case .custom(let closure):
            return closure(value)
        }
    }
}

public extension Redactable {
    
    /// Returns a formatted string from the normalised value.
    ///
    /// If the result is JSON-compatible, it returns a pretty-printed JSON string.
    /// Otherwise, falls back to Swift's `description`.
    ///
    /// - Parameter parentKeys: Redacted keys from upstream context.
    /// - Returns: A user-readable string representation.
    func normalisedDescription(redacting parentKeys: Set<String> = []) -> String {
        let value = normalised(redacting: parentKeys)

        if JSONSerialization.isValidJSONObject(value),
           let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys]),
           let string = String(data: data, encoding: .utf8) {
            return string
        }

        if let encodable = value as? Encodable {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(AnyEncodable(encodable)),
               let string = String(data: data, encoding: .utf8) {
                return string
            }
        }

        return String(describing: value)
    }
}

public extension Redactable {
    
    /// Wraps a `Date` using ISO 8601 format.
    static func isoDate(_ date: Date) -> Redactable {
        .value(date, .iso8601)
    }

    /// Wraps a `Date` using short date format.
    static func shortDate(_ date: Date) -> Redactable {
        .value(date, .shortDate)
    }

    /// Wraps a `Date` using time-only format.
    static func timeOnly(_ date: Date) -> Redactable {
        .value(date, .timeOnly)
    }
}

public extension Redactable {
    
    /// Creates a `Redactable` wrapper from any value.
    ///
    /// - Parameter value: The value to wrap.
    init(any value: Any) {
        switch value {
        case let redactable as Redactable:
            self = redactable
        case let redactable as DebugRedactable:
            self = .value(redactable)
        case let dict as [String: Any]:
            self = .dictionary(dict)
        case let array as [Any]:
            self = .array(array)
        default:
            self = .value(value)
        }
    }
}

/// A lightweight wrapper for encoding any `Encodable` value.
private struct AnyEncodable: Encodable {
    
    private let encodeFunc: (Encoder) throws -> Void

    /// Wraps a value for encoding.
    ///
    /// - Parameter value: The encodable value.
    public init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }

    public func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
