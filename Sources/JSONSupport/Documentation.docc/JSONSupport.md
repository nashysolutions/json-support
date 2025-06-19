# ``JSONSupport``

A utility for inspecting or generating structured, redaction-safe debug output. It’s designed for logging and diagnostics in environments where user data must be handled carefully.

## Overview 

At the heart of this system is the `DebugRedactable` protocol. Types that conform can describe their internal structure using dictionaries while selectively hiding values based on declared redaction rules. This allows debug output to be safely used in logs, UI previews, and development tools.

The system supports:
- Redacting sensitive keys using `redactedDebugKeys`
- Nesting and composing redaction across types
- Custom formatting of values (especially `Date`)
- Normalising structured data for log output
- Integration with app types like CloudKit models

---

## Topics

- <doc:RedactionBasics>
- <doc:DebugDescribableConformance>
- <doc:CustomValueFormatting>
- <doc:NormalisedOutput>
- <doc:DebugDictionaryBuilder>
- <doc:IntegrationExamples>
