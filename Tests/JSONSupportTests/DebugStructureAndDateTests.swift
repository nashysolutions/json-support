//
//  DebugStructureAndDateTests.swift
//  json-support
//
//  Created by Robert Nash on 12/06/2025.
//

import Foundation
import Testing
import JSONSupport

@Suite("Date and Structured Data Handling")
struct DebugStructureAndDateTests {

    @Test("Sanitises date values with current locale formatting")
    func sanitisesDateWithStableFormat() throws {
        let input: [String: Any] = ["value": Date(timeIntervalSince1970: 0)]
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        let date = try parsed.require("value", as: String.self)
        #expect(date.contains("1970"))
        #expect(parsed.countLeafValues == 1)
    }
    
    @Test("Sanitises nested dictionary structures")
    func sanitisesNestedDictionary() throws {
        let input: [String: Any] = [
            "outer": ["inner": ["key": "value"]]
        ]
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        let outer = try parsed.requireNestedObject("outer")
        let inner = try outer.requireNestedObject("inner")
        let value = try inner.require("key", as: String.self)
        
        #expect(value == "value")
        #expect(parsed.countLeafValues == 1)
    }
    
    @Test("Sanitises arrays of mixed values")
    func sanitisesArrayOfMixedValues() throws {
        let input: [String: Any] = [
            "values": ["text", 123, Date(timeIntervalSince1970: 0)]
        ]
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        let values = try parsed.requireArray("values")
        #expect(values.count == 3)
        #expect(values.contains(where: { ($0 as? String) == "text" }))
        #expect(values.contains(where: { ($0 as? Int) == 123 }))
        #expect(values.contains(where: { ($0 as? String)?.contains("1970") == true }))
    }

    @Test("Serialises arrays containing mixed primitive and complex types")
    func handlesArraysOfMixedTypes() throws {
        let input: [String: Any] = [
            "values": [
                1,
                "two",
                Date(timeIntervalSince1970: 0)
            ]
        ]
        
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        #expect(parsed.topLevelKeyCount == 1)
        let values = try parsed.requireArray("values")
        
        #expect(values.count == 3)
        #expect(values[0] as? Int == 1)
        #expect(values[1] as? String == "two")
        #expect(String(describing: values[2]).contains("1970"))
    }

    @Test("Serialises dictionaries with nested structures and validates inner values")
    func handlesNestedDictionaries() throws {
        
        let input: [String: Any] = [
            "outer": [
                "inner": [
                    "name": "Alice",
                    "age": 30
                ]
            ]
        ]
        
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        #expect(parsed.topLevelKeyCount == 1)
        
        let outer = try parsed.requireNestedObject("outer")
        let inner = try outer.requireNestedObject("inner")
        let name = try inner.require("name", as: String.self)
        let age = try inner.require("age", as: Int.self)
        
        #expect(name == "Alice")
        #expect(age == 30)
        #expect(parsed.countLeafValues == 2) // "Alice" and 30
    }
}
