# json-support

A lightweight Swift package for bundling, inspecting, and pretty-printing JSON dictionaries.

This package includes:

- `DebugDictionaryBuilder`: pretty-prints `[String: Any]` as JSON for debugging
- `JSONInspector`: inspects JSON output and assists with test assertions
- `DebugDescribable`: redacts and formats model data for safe output

---

## Features

- ✅ Pretty-printed JSON debug output
- ✅ Sanitises unsupported types (`Date`, `URL`, etc.)
- ✅ Handles nested dictionaries and arrays
- ✅ Stable and locale-independent date formatting (`yyyy-MM-dd HH:mm:ss Z`)
- ✅ Automatically removes escaped slashes (`\/`)
- ✅ Optional redaction of sensitive fields
- ✅ JSON inspection for test validation (via `ParsedJSONKit`)
- ✅ Model-level integration with `DebugDescribable`

---

## SPM Integration

```swift
.target(
  name: "YourTarget",
  dependencies: [
    .product(name: "JSONSupport", package: "json-support")
  ]
)
```

---

## Usage

### Debug Output

```swift
let data: [String: Any] = [
    "name": "Alice",
    "joined": Date(timeIntervalSince1970: 0),
    "profile": URL(string: "https://example.com")!,
    "metadata": [
        "score": 42,
        "active": true
    ]
]

let builder = DebugDictionaryBuilder()
let debugString = builder.makeDescription(from: data)
print(debugString)
```

Prints:

```json
{
  "name" : "Alice",
  "joined" : "1970-01-01 00:00:00 +0000",
  "profile" : "https://example.com",
  "metadata" : {
    "score" : 42,
    "active" : true
  }
}
```

---

### Redacting Sensitive Values

You can redact specific fields based on key name matches:

```swift
let builder = DebugDictionaryBuilder(redactKeys: ["password", "token"])
let output = builder.makeDescription(from: [
    "username": "Alice",
    "token": "abc123"
])
```

Prints:

```json
{
  "username" : "Alice",
  "token" : "[REDACTED]"
}
```

---

### Redacting in Models

```swift
struct Token: DebugDescribable {
    let value: String
    let expiry: Date

    enum DebugKeys: String, CaseIterable {
        case value, expiry
    }

    static var redactedDebugKeys: Set<String> {
        #if DEBUG
        []
        #else
        [DebugKeys.value.rawValue]
        #endif
    }

    func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
        redact([
            "token_value": value,
            "expiry": expiry
        ], including: mergedRedactedKeys(parentKeys))
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
        #if DEBUG
        []
        #else
        [DebugKeys.id.rawValue]
        #endif
    }

    func debugDictionary(redacting parentKeys: Set<String>) -> [String: Any] {
        redact([
            "id": id.uuidString,
            "name": name,
            "token": token
        ], including: mergedRedactedKeys(parentKeys))
    }
}

let token = Token(value: "abc123", expiry: Date())
let user = User(id: UUID(), name: "Alice", token: token)

print(user)

{
  "id" : "[REDACTED]",
  "name" : "Alice",
  "token" : {
    "token_value" : "[REDACTED]",
    "expiry" : "2025-06-18T04:19:02Z"
  }
}
```

---

## Testing & Inspection

Use `JSONInspector` to inspect JSON structure in tests:

```swift
let builder = DebugDictionaryBuilder()
let json = builder.makeDescription(from: ["key": "value"])
let parsed = try JSONInspector(json)

#expect(parsed.topLevelKeyCount == 1)
#expect(try parsed.require("key", as: String.self) == "value")
```

---

## Documentation

📘 Visit the Documentation tab in Xcode or browse via DocC to explore these articles.
