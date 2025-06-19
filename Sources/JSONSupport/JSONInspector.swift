//
//  JSONInspector.swift
//  ParsedJSONKit
//
//  Created by Robert Nash on 12/06/2025.
//

import Foundation

/// A lightweight utility for parsing and inspecting flat or nested JSON objects
/// represented as Swift dictionaries, typically for test assertions.
public struct JSONInspector {
    
    /// The root deserialised JSON value.
    private let root: Any

    /// Creates a `ParsedJSON` instance from a JSON string.
    ///
    /// - Parameter jsonString: A UTF-8 encoded JSON string representing a dictionary.
    /// - Throws: `ParsedJSONError.invalidUTF8` if the string can't be encoded,
    ///           or `JSONSerialization` errors if the string is not valid JSON.
    public init(_ jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw ParsedJSONError.invalidUTF8
        }

        self.root = try JSONSerialization.jsonObject(with: data, options: [])
    }

    /// The number of top-level keys in the parsed dictionary.
    public var topLevelKeyCount: Int {
        (root as? [String: Any])?.count ?? 0
    }

    /// Returns a typed value for a given key, or throws if the key is missing or the type is incorrect.
    ///
    /// - Parameters:
    ///   - key: The dictionary key to look up.
    ///   - type: The expected type of the value (defaults to inferring `T`).
    /// - Returns: The typed value at the given key.
    /// - Throws: `ParsedJSONError.notADictionary`, `ParsedJSONError.missingKey`, or `ParsedJSONError.typeMismatch`.
    public func require<T>(_ key: String, as type: T.Type = T.self) throws -> T {
        guard let dict = root as? [String: Any] else {
            throw ParsedJSONError.notADictionary
        }
        guard let value = dict[key] else {
            throw ParsedJSONError.missingKey(key)
        }
        guard let typed = value as? T else {
            throw ParsedJSONError.typeMismatch(
                expected: String(describing: T.self),
                actual: String(describing: value)
            )
        }
        return typed
    }

    /// Parses a nested dictionary value and returns it as a `ParsedJSON` instance.
    ///
    /// - Parameter key: The key whose value is expected to be a nested dictionary.
    /// - Returns: A `ParsedJSON` instance wrapping the nested dictionary.
    /// - Throws: If the key is missing or its value is not a `[String: Any]`.
    public func requireNestedObject(_ key: String) throws -> JSONInspector {
        let nested: [String: Any] = try require(key)
        return JSONInspector(nested)
    }

    /// Returns an array value for a given key.
    ///
    /// - Parameter key: The dictionary key to look up.
    /// - Returns: An array value.
    /// - Throws: If the key is missing or not an array.
    public func requireArray(_ key: String) throws -> [Any] {
        return try require(key)
    }

    /// Creates a `ParsedJSON` instance from an already-parsed dictionary.
    ///
    /// - Parameter object: A `[String: Any]` dictionary.
    private init(_ object: [String: Any]) {
        self.root = object
    }
}

public extension JSONInspector {
    
    /// Returns the total number of non-container values across the entire JSON hierarchy.
    var countLeafValues: Int {
        return countLeaves(in: root)
    }

    private func countLeaves(in value: Any) -> Int {
        switch value {
        case is String, is Int, is Double, is Bool, is NSNull:
            return 1
        case let dict as [String: Any]:
            return dict.values.reduce(0) { $0 + countLeaves(in: $1) }
        case let array as [Any]:
            return array.reduce(0) { $0 + countLeaves(in: $1) }
        default:
            return 1 // For non-standard types, assume leaf (safe fallback)
        }
    }
}

extension JSONInspector: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        (root as? [String: Any]).map {
            let builder = DebugDictionaryBuilder()
            return builder.makeDescription(from: $0)
        } ?? String(describing: root)
    }
}

/// Errors thrown by `ParsedJSON` methods when decoding or type-checking fails.
public enum ParsedJSONError: Error, CustomDebugStringConvertible {
    
    /// The input string could not be converted to UTF-8 data.
    case invalidUTF8

    /// The root JSON object was not a dictionary.
    case notADictionary

    /// A required key was not found in the dictionary.
    case missingKey(String)

    /// A value was found but it did not match the expected type.
    case typeMismatch(expected: String, actual: String)

    /// A debug-friendly string describing the error.
    public var debugDescription: String {
        switch self {
        case .invalidUTF8:
            return "Failed to decode JSON string as UTF-8 data."
        case .notADictionary:
            return "Expected top-level dictionary, got something else."
        case .missingKey(let key):
            return "Missing required key: \(key)"
        case .typeMismatch(let expected, let actual):
            return "Expected value of type \(expected), but got: \(actual)"
        }
    }
}
