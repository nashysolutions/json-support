# Using Redaction in Practice

This article provides real-world examples of how to integrate the redaction system into your app, backend, or diagnostics workflow.

## Logging an iCloud Record Safely

To log a CloudKit record or related model conforming to `DebugDescribable`, use the `debugDescription` property:

```swift
let record: CloudMove = ...
logger.debug("Move: \(record)")
```

If the record includes sensitive fields (e.g. names, IDs, timestamps), they will be redacted based on your type's `redactedDebugKeys`.

## Inspecting App State

You can create summarised or redacted dictionaries from in-memory values:

```swift
let snapshot: [String: Any] = [
    "userId": "abc-123",
    "score": 99,
    "lastSeen": Date()
]

let builder = DebugDictionaryBuilder(redactKeys: ["userId"])
let description = builder.makeDescription(from: snapshot)

print(description)
```

This prints a pretty-printed JSON string with the `userId` redacted.

## Debugging Payloads with `flatten`

Sometimes a value isn’t easily loggable. Use `Redactable(any:)` to flatten complex structures:

```swift
let payload: [String: Any] = ...
let redactable = Redactable(any: payload)
let summary = redactable.flattenedDescription()

logger.info("Payload summary: \(summary)")
```

This is especially helpful for inspecting or snapshotting deeply nested objects (e.g. `[String: Any]` results, third-party data, etc).

---

Explore the rest of the catalogue to learn more about defining redacted fields, custom value formatting, and flattening logic.
