# Redaction Basics

Redaction is a fundamental part of the `DebugDescribable` system. It ensures that sensitive or private information does not appear in debug output by selectively masking specific values based on keys.

## Overview

Types conforming to `DebugRedactable` declare which keys they consider sensitive using the static property `redactedDebugKeys`.

```swift
public static var redactedDebugKeys: Set<String> {
    ["password", "token"]
}
```

These keys are matched during debug output rendering. Any key that matches the set—either locally or inherited via a parent context—is replaced with the string `[REDACTED]`.

## Nested Redaction

Redaction is recursive. Nested values that conform to `DebugRedactable` will also have their `redactedDebugKeys` merged with any parent redaction context.

```swift
func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
    let mergedKeys = parentKeys.union(Self.redactedDebugKeys)
    return redact(myDictionary, including: mergedKeys)
}
```

## Redaction Example

Given the following struct:

```swift
struct User: DebugDescribable {
    var username: String
    var password: String

    static var redactedDebugKeys: Set<String> {
        ["password"]
    }

    func debugDictionary(redacting parentKeys: Set<String>) -> [String : Any] {
        [
            "username": username,
            "password": password
        ]
    }
}
```

Calling `debugDescription` on a `User` instance will output:

```json
{
  "username": "alice",
  "password": "[REDACTED]"
}
```

## Best Practices

- Always include `recordName`, `token`, `email`, and similar identifiers in redacted keys.
- Redact parent and child keys for consistency (`mergedRedactedKeys` helps).
- Avoid over-redacting, especially for debugging IDs that aren’t user-facing.
- When defining redacted keys, use an internal `enum` conforming to `CaseIterable` to ensure consistency:

```swift
enum DebugKeys: String, CaseIterable {
    case username
    case password
    case email
}

static var redactedDebugKeys: Set<String> {
    [DebugKeys.password.rawValue, DebugKeys.email.rawValue]
}
```

- If needed, vary redaction rules per environment using compile-time flags like:

```swift
#if DEBUG
return []
#else
return ["token", "password"]
#endif
```

## See Also

- <doc:DebugDescribableConformance>
- <doc:DebugDictionaryBuilder>
