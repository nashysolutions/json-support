//
//  RedactableValue.swift
//  json-support
//
//  Created by Robert Nash on 17/06/2025.
//

import Foundation

let value_placeholder = "value"

/// A wrapper for any value that can be formatted and included in a debug dictionary,
/// with special formatting options for `Date` types.
///
/// `RedactableValue` is primarily used for representing values in structured debug
/// output, conforming to `DebugRedactable`. It supports optional values, custom formatting,
/// and human-readable or ISO8601 date output.
public struct RedactableValue: DebugRedactable {

    /// The raw value to be formatted.
    public let value: Any

    /// The formatting style to apply, particularly relevant for `Date` values.
    public let format: RedactableDateFormatStyle

    /// Creates a new `RedactableValue` with a specified format.
    ///
    /// - Parameters:
    ///   - value: The value to wrap and format.
    ///   - format: The formatting style to use. Defaults to `.default`.
    public init(_ value: Any, format: RedactableDateFormatStyle = .default) {
        self.value = value
        self.format = format
    }

    /// A set of keys that should be redacted. This type does not redact any keys by default.
    public static var redactedDebugKeys: Set<String> { [] }

    /// Returns a formatted representation of the wrapped value as a debug dictionary.
    ///
    /// - Parameter parentKeys: The set of keys to redact (not used in this implementation).
    /// - Returns: A dictionary with a single `"value"` key and a formatted string.
    public func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
        [value_placeholder: formatValue()]
    }

    /// Formats the underlying value based on the configured format.
    ///
    /// Supports `Date`, `Optional`, and `Custom` formatter styles.
    ///
    /// - Returns: A formatted string representation of the value.
    private func formatValue() -> String {
        // Handle Optional<Wrapped>
        let unwrapped = unwrap(value)

        switch format {
        case .default:
            return string(for: unwrapped)

        case .iso8601:
            if let date = unwrapped as? Date {
                return ISO8601DateFormatter().string(from: date)
            }
            return string(for: unwrapped)

        case .shortDate:
            if let date = unwrapped as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter.string(from: date)
            }
            return string(for: unwrapped)

        case .timeOnly:
            if let date = unwrapped as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter.string(from: date)
            }
            return string(for: unwrapped)

        case .custom(let closure):
            return closure(unwrapped)
        }
    }

    /// Unwraps an `Optional` value if necessary.
    ///
    /// - Parameter any: A potentially optional value.
    /// - Returns: The unwrapped value, or `"nil"` if `nil`.
    private func unwrap(_ any: Any) -> Any {
        let mirror = Mirror(reflecting: any)
        if mirror.displayStyle == .optional {
            return mirror.children.first?.value ?? "nil"
        }
        return any
    }

    /// Returns a string description for the given value.
    ///
    /// - Parameter value: The value to describe.
    /// - Returns: A string representation, using `.description` or raw string if available.
    private func string(for value: Any) -> String {
        if let v = value as? String { return v }
        return String(describing: value)
    }
}

extension RedactableValue {

    /// Creates a `RedactableValue` with ISO 8601 formatting.
    ///
    /// - Parameter date: The date to format.
    /// - Returns: A `RedactableValue` with `.iso8601` formatting.
    public static func isoDate(_ date: Date) -> RedactableValue {
        RedactableValue(date, format: .iso8601)
    }

    /// Creates a `RedactableValue` with short date formatting (e.g. `dd/MM/yy`).
    ///
    /// - Parameter date: The date to format.
    /// - Returns: A `RedactableValue` with `.shortDate` formatting.
    public static func shortDate(_ date: Date) -> RedactableValue {
        RedactableValue(date, format: .shortDate)
    }

    /// Creates a `RedactableValue` with time-only formatting (e.g. `HH:mm`).
    ///
    /// - Parameter date: The date to format.
    /// - Returns: A `RedactableValue` with `.timeOnly` formatting.
    public static func time(_ date: Date) -> RedactableValue {
        RedactableValue(date, format: .timeOnly)
    }
}
