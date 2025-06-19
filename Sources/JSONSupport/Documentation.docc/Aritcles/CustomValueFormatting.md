# Customising Value Formatting

This article explores how to use `RedactableValue` and `RedactableDateFormatStyle` to control how values — especially dates and optional values — are represented in debug output.

## .default vs .iso8601

By default, `RedactableValue` uses `.default` formatting, which calls `String(describing:)` on the unwrapped value.

If the value is a `Date` and `.iso8601` is specified, it will be formatted using `ISO8601DateFormatter`:

```swift
let date = Date()
let value = RedactableValue(date, format: .iso8601)
```

This produces output such as:

```json
{
  "value": "2025-06-18T14:23:00Z"
}
```

## .shortDate, .timeOnly, and .custom

You can choose other styles using:

- `.shortDate`: Formats the date using `DateFormatter` with `.short` style.
- `.timeOnly`: Formats only the time portion.
- `.custom`: Lets you supply your own closure `(Any) -> String`.

```swift
RedactableValue.shortDate(Date())
RedactableValue.time(Date())
RedactableValue(Date(), format: .custom { value in
    "\(value)!"
})
```

These styles are especially useful when you want to align formatting with UI expectations or logs.

## Example with Date and Optional

Optional values are automatically unwrapped, so the following:

```swift
let optionalDate: Date? = Date()
let value = RedactableValue(optionalDate, format: .shortDate)
```

...will correctly display a short formatted date. If the optional is `nil`, it will output `"nil"`.

This makes `RedactableValue` ideal for use in redacted debug dictionaries that need to handle a wide variety of types safely and predictably.
