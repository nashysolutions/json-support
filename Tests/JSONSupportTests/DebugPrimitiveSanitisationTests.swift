//
//  DebugPrimitiveSanitisationTests.swift
//  json-support
//
//  Created by Robert Nash on 12/06/2025.
//

import Foundation
import Testing
import JSONSupport

@Suite("Primitive Value Sanitisation")
struct DebugPrimitiveSanitisationTests {

    @Test("Serialises flat dictionaries containing primitive Swift types")
    func serialisesPrimitiveValues() throws {
        let input: [String: Any] = [
            "name": "Alice",
            "age": 30,
            "isActive": true
        ]
        
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        #expect(parsed.topLevelKeyCount == 3)
        #expect(try parsed.require("name", as: String.self) == "Alice")
        #expect(try parsed.require("age", as: Int.self) == 30)
        #expect(try parsed.require("isActive", as: Bool.self) == true)
    }

    @Test("Sanitises plain string values")
    func sanitisesString() throws {
        
        let input: [String: Any] = [
            "value": "Hello"
        ]
        
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        #expect(parsed.topLevelKeyCount == 1)
        
        let value = try parsed.require("value", as: String.self)
        #expect(value == "Hello")
        #expect(parsed.countLeafValues == 1)
    }
    
    @Test("Sanitises integer values")
    func sanitisesInt() throws {
        let input: [String: Any] = ["value": 42]
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        #expect(try parsed.require("value", as: Int.self) == 42)
        #expect(parsed.countLeafValues == 1)
    }
    
    @Test("Sanitises double values")
    func sanitisesDouble() throws {
        let input: [String: Any] = ["value": 3.14]
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        #expect(try parsed.require("value", as: Double.self) == 3.14)
        #expect(parsed.countLeafValues == 1)
    }
    
    @Test("Sanitises boolean values")
    func sanitisesBool() throws {
        let input: [String: Any] = ["value": true]
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        #expect(try parsed.require("value", as: Bool.self) == true)
        #expect(parsed.countLeafValues == 1)
    }
    
    @Test("Sanitises null values")
    func sanitisesNull() throws {
        let input: [String: Any] = ["value": NSNull()]
        let builder = DebugDictionaryBuilder()
        let json = builder.makeDescription(from: input)
        let parsed = try JSONInspector(json)
        
        let value = try parsed.require("value", as: [String: Any].self)
        #expect(value["value"] as? String == "[REDACTED]")
        #expect(value["isNilOrEmpty"] as? Bool == true)
    }
}
