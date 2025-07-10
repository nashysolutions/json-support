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
        _debugDescription(
            file: #fileID,
            function: #function,
            line: #line
        )
    }

    private func _debugDescription(
        file: String,
        function: String,
        line: Int
    ) -> String {
        if DebugRecursionFlag.isDebugging {
            return "<debugDescription recursion detected at \(file):\(line) in \(function) [\(type(of: self))]>"
        }

        return DebugRecursionFlag.$isDebugging.withValue(true) {
            let dict = debugDictionary(redacting: Self.redactedDebugKeys)
            return DebugDictionaryBuilder().makeDescription(from: dict)
        }
    }
}

/// A task-local flag used to prevent infinite recursion in `debugDescription` calls.
///
/// This flag is used within the `DebugDescribable` protocol extension to detect
/// and short-circuit recursive attempts to generate a debug description—typically caused
/// when `debugDictionary(redacting:)` inadvertently accesses `debugDescription`.
///
/// The use of `@TaskLocal` ensures that the flag is scoped to the current structured
/// concurrency task, making it thread-safe and avoiding global state mutation.
private enum DebugRecursionFlag {
    
    /// Indicates whether the current task is already performing a `debugDescription` operation.
    ///
    /// Set to `true` during execution of `DebugDescribable.debugDescription` and used to detect
    /// re-entrant calls which would otherwise result in infinite recursion.
    ///
    /// - Note: This flag is automatically reset when the `withValue(true)` scope exits.
    @TaskLocal static var isDebugging: Bool = false
}
