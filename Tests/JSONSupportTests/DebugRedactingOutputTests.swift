//
//  DebugRedactingOutputTests.swift
//  json-support
//
//  Created by Robert Nash on 12/06/2025.
//

import Foundation
import Testing
import JSONSupport

@Suite("DebugDictionaryBuilder – Redaction Output")
struct DebugRedactingOutputTests {

    @Test("Redacted string includes type and isNilOrEmpty flag")
    func redactsStringWithTypeInfo() throws {
        let builder = DebugDictionaryBuilder(redactKeys: ["secret"])
        let json = builder.makeDescription(from: ["token": "my_secret_value"])
        let parsed = try JSONInspector(json)
        let token = try parsed.requireNestedObject("token")

        #expect(try token.require("value", as: String.self) == "[REDACTED]")
        #expect(try token.require("type", as: String.self) == "String")
        #expect(try token.require("isNilOrEmpty", as: Bool.self) == false)
    }

    @Test("Redacted number includes type info")
    func redactsNumberWithTypeInfo() throws {
        let builder = DebugDictionaryBuilder(redactKeys: ["42"])
        let json = builder.makeDescription(from: ["score": 42])
        let parsed = try JSONInspector(json)
        let score = try parsed.requireNestedObject("score")

        #expect(try score.require("value", as: String.self) == "[REDACTED]")
        #expect(try score.require("type", as: String.self) == "Int")
    }

    @Test("Redacted unsupported type includes type info")
    func redactsUnsupportedWithTypeInfo() throws {
        struct Custom {}
        let builder = DebugDictionaryBuilder(redactKeys: ["Custom"])
        let json = builder.makeDescription(from: ["thing": Custom()])
        let parsed = try JSONInspector(json)
        let thing = try parsed.requireNestedObject("thing")

        #expect(try thing.require("value", as: String.self) == "[REDACTED]")
        #expect(try thing.require("type", as: String.self) == "Custom")
    }
}
