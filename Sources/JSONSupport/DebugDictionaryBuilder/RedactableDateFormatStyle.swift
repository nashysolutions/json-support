//
//  RedactableDateFormatStyle.swift
//  json-support
//
//  Created by Robert Nash on 18/06/2025.
//

import Foundation

/// A style used to control how date values are formatted in debug output.
public enum RedactableDateFormatStyle {
    
    /// Uses the default `String(describing:)` formatting for values.
    case `default`
    
    /// Formats `Date` values using the ISO 8601 standard.
    ///
    /// Non-`Date` values fall back to default formatting.
    case iso8601
    
    /// Formats `Date` values using the system's `.short` date style.
    ///
    /// Non-`Date` values fall back to default formatting.
    case shortDate
    
    /// Formats `Date` values showing only the time component using `.short` time style.
    ///
    /// Non-`Date` values fall back to default formatting.
    case timeOnly
    
    /// A custom formatting closure to convert values to strings.
    ///
    /// Use this to provide fine-grained control over how individual values are represented in debug output.
    case custom((Any) -> String)
}
