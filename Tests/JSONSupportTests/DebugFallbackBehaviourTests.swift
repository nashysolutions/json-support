//
//  DebugFallbackBehaviourTests.swift
//  json-support
//
//  Created by Robert Nash on 12/06/2025.
//

import Foundation
import Testing
import JSONSupport

@Suite
struct DebugFallbackBehaviourTests {
    
    @Test("Falls back to string representation for values not natively JSON-serialisable")
    func sanitisesUnsupportedTypes() throws {
        
        let input: [String: Any] = [
            "date": Date(timeIntervalSince1970: 1),
            "url": URL(string: "https://example.com")!
        ]
        
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        // Assert key count
        #expect(parsed.topLevelKeyCount == 2)
        
        // Assert formatted date
        let dateValue = try parsed.require("date", as: String.self)
        #expect(dateValue.contains("1970"))
        
        // Assert URL stringified
        let url = try parsed.require("url", as: String.self)
        #expect(url == "https://example.com")
    }
    
    @Test("Falls back to string description for non-JSON convertible values")
    func fallbackForNonJSONConvertible() throws {
        
        struct NotEncodable {}
        
        let input: [String: Any] = [
            "bad": NotEncodable()
        ]
        
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        #expect(parsed.topLevelKeyCount == 1)
        
        let badValue = try parsed.require("bad", as: String.self)
        
        // Assert the fallback uses String(describing:) output
        #expect(badValue.contains("NotEncodable"))
    }
    
    @Test("Falls back to string description for unsupported types")
    func sanitisesUnsupportedTypeUsingStringDescribing() throws {
        struct Custom {}
        let input: [String: Any] = ["custom": Custom()]
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        let string = try parsed.require("custom", as: String.self)
        #expect(string.contains("Custom"))
    }
}
