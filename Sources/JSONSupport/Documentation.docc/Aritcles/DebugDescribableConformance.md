# Making Your Types Debug Describable

Conforming to `DebugDescribable` allows your types to generate structured debug output that is safe, redacted, and easy to inspect. This article explains how to adopt the protocol, manage redaction, and control output formatting.

## Requirements

To conform to `DebugDescribable`, a type must implement the following:

- `debugDictionary(redacting:)` — returns a `[String: Any]` representation of the internal state
- `static var redactedDebugKeys: Set<String>` — identifies which keys should be hidden in debug output

In addition, `DebugDescribable` extends `CustomDebugStringConvertible`, so your type gets a default implementation of `debugDescription` automatically.

## How `debugDescription` is Built

The default `debugDescription` uses the `debugDictionary(redacting:)` output and formats it using `DebugDictionaryBuilder`:

```swift
var debugDescription: String {
    let dict = debugDictionary(redacting: Self.redactedDebugKeys)
    return DebugDictionaryBuilder().makeDescription(from: dict)
}
```

This ensures consistent formatting across types, including support for nested redaction and pretty-printing.

## Redaction Propagation with `mergedRedactedKeys`

When implementing `debugDictionary`, you should call `mergedRedactedKeys(...)` to merge any redaction context passed from the parent:

```swift
let merged = mergedRedactedKeys(parentKeys)
```

Then, pass that merged set into the `redact(_:including:)` helper:

```swift
return redact(myDictionary, including: merged)
```

This ensures that if a parent type chooses to redact certain fields, your nested type respects those decisions.

## Example: Conforming a User and Token Type

Let’s say we have two models—`User` and `Token`. Both hold values that could be considered sensitive.

```swift
struct Token: DebugDescribable {
    let value: String
    let expiry: Date

    enum DebugKeys: String, CaseIterable {
        case value, expiry
    }

    static var redactedDebugKeys: Set<String> {
        [DebugKeys.value.rawValue]
    }

    func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
        let merged = mergedRedactedKeys(parentKeys)
        return redact([
            "value": value,
            "expiry": expiry
        ], including: merged)
    }
}

struct User: DebugDescribable {
    let id: UUID
    let name: String
    let token: Token

    enum DebugKeys: String, CaseIterable {
        case id, name, token
    }

    static var redactedDebugKeys: Set<String> {
        [DebugKeys.id.rawValue]
    }

    func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
        let merged = mergedRedactedKeys(parentKeys)
        return redact([
            "id": id.uuidString,
            "name": name,
            "token": token
        ], including: merged)
    }
}
```

Calling `debugDescription` on a `User` instance will automatically propagate redaction to the nested `Token`:

```json
{
  "id": "[REDACTED]",
  "name": "alice",
  "token": {
    "value": "[REDACTED]",
    "expiry": "2025-06-18T08:45:00Z"
  }
}
```

## See Also

- <doc:RedactionBasics>
- <doc:CustomValueFormatting>
