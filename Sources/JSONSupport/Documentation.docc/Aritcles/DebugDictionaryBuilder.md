# ``doc:DebugDictionaryBuilder``

## Using `DebugDictionaryBuilder`

`DebugDictionaryBuilder` is a utility for generating readable, structured representations of debug information from `[String: Any]` dictionaries. It supports intelligent redaction and flattening of nested values for safe logging and inspection.

---

## Initialising with `redactKeys`

You can initialise a `DebugDictionaryBuilder` with a set of keys that should be redacted in the final output. These keys are matched by case-insensitive containment.

```swift
let builder = DebugDictionaryBuilder(redactKeys: ["token", "password"])
```

Any key in the dictionary (or its nested values) that includes "token" or "password" will have its associated value replaced with `[REDACTED]`.

---

## `.makeDescription(...)` vs `.flatCompactDescription(...)`

### `.makeDescription(...)`

This method produces a **pretty-printed** JSON string from the input dictionary:

```swift
let json = builder.makeDescription(from: [
    "userId": "abc123",
    "accessToken": "secret123"
])
```

If `accessToken` matches a redacted key, the output will be:

```json
{
  "userId": "abc123",
  "accessToken": "[REDACTED]"
}
```

### `.flatCompactDescription(...)`

This variant produces a **compact**, one-line JSON string suitable for logs and metrics:

```swift
let json = builder.flatCompactDescription(from: [
    "timestamp": Date(),
    "event": "login"
])
```

This uses `Redactable.flattened(...)` under the hood to simplify nested types and produce a more digestible format for output.

---

## Fallback sanitisation for unstructured values

When encountering unknown types or non-conforming values, `DebugDictionaryBuilder` falls back to a generic sanitisation strategy. For example:

```swift
let dict: [String: Any] = [
    "customType": MyType(),
    "nilValue": NSNull()
]
```

Will be represented like:

```json
{
  "customType": "MyType(...)",
  "nilValue": {
    "value": "[REDACTED]",
    "type": "Null",
    "isNilOrEmpty": true
  }
}
```

This ensures all values are presented meaningfully without crashing or leaking sensitive content.

---

## See Also

- ``doc:RedactionBasics``
- ``doc:FlattenedOutput``

