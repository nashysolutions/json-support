# Generating Normalised Output

When preparing debug information for logs, it's often useful to convert nested or complex structures into a simpler form. The `Redactable` type provides methods to **normalise** its values — producing clean, serialisation-ready output that can be safely printed or transmitted.

## Normalising Structured Values

The method `normalised(redacting:)` walks the contents of a `Redactable` value and applies:

- Redaction policies using `redactedDebugKeys`
- Custom formatting of dates via `RedactableDateFormatStyle`
- Unwrapping of optionals and non-conforming values

It returns a fully resolved structure of `[String: Any]`, `[Any]`, or primitive values.

```swift
let redactable: Redactable = .dictionary([
  "username": "alice",
  "password": "secret"
])

let output = redactable.normalised(redacting: ["password"])
// [
//   "username": "alice",
//   "password": "[REDACTED]"
// ]
```

## Creating Summaries with `normalisedDescription`

The `normalisedDescription()` method turns the normalised structure into a human-readable JSON string. It’s ideal for writing to logs or displaying in developer tools.

```swift
print(redactable.normalisedDescription(redacting: ["password"]))
```

This prints:

```json
{
  "username": "alice",
  "password": "[REDACTED]"
}
```

If redaction or formatting fails, it falls back to a generic `String(describing:)`.

## Example: Log-Friendly Output

Consider a nested structure like this:

```swift
let user = Redactable.dictionary([
    "profile": [
        "email": "user@example.com",
        "created": Date()
    ],
    "auth": [
        "token": "abc123"
    ]
])
```

Calling `normalisedDescription(redacting: ["token"])` will apply:

- Recursion through the nested dictionary
- Redaction of `"token"` only
- ISO8601 formatting for `Date`

### Output

```json
{
  "profile": {
    "email": "user@example.com",
    "created": "2025-06-18T12:00:00Z"
  },
  "auth": {
    "token": "[REDACTED]"
  }
}
```

## See Also

- <doc:DebugDescribableConformance>
- <doc:DebugDictionaryBuilder>
