import Testing
import JSONSupport

/// A test suite for verifying the behaviour of the `JSONInspector` type,
/// which provides type-safe access to parsed JSON structures.
@Suite("JSONInspector – Basic Parsing Tests")
struct ParsedJSONTests {
    
    /// Tests that a well-formed JSON string containing a flat dictionary
    /// of primitive types is parsed correctly.
    ///
    /// - Verifies:
    ///   - The top-level dictionary contains 3 keys.
    ///   - The values for "name", "age", and "isAdmin" are correctly typed and match expected values.
    @Test("Parses flat JSON string into a typed dictionary")
    func parsesValidJSONStringIntoDictionary() throws {
        let json = """
        {
            "name": "Alice",
            "age": 30,
            "isAdmin": true
        }
        """

        let parsed = try JSONInspector(json)
        #expect(parsed.topLevelKeyCount == 3)
        #expect(try parsed.require("name", as: String.self) == "Alice")
        #expect(try parsed.require("age", as: Int.self) == 30)
        #expect(try parsed.require("isAdmin", as: Bool.self) == true)
    }
    
    /// Tests that the `JSONInspector` correctly traverses nested dictionaries.
     ///
     /// - Input:
     ///   ```json
     ///   {
     ///     "outer": {
     ///       "inner": {
     ///         "key": 42
     ///       }
     ///     }
     ///   }
     ///   ```
     ///
     /// - Verifies:
     ///   - The outer dictionary contains one key.
     ///   - The nested value is retrievable with correct type.
     @Test("Handles nested dictionaries and retrieves inner values")
     func handlesNestedDictionaries() throws {
         let json = """
         {
             "outer": {
                 "inner": {
                     "name": "Alice",
                     "age": 42
                 }
             }
         }
         """

         let parsed = try JSONInspector(json)
         #expect(parsed.topLevelKeyCount == 1) // outer
         #expect(parsed.countLeafValues == 2) // alice, 42

         let outer = try parsed.requireNestedObject("outer")
         let inner = try outer.requireNestedObject("inner")
         let name = try inner.require("name", as: String.self)
         let age = try inner.require("age", as: Int.self)

         #expect(name == "Alice")
         #expect(age == 42)
     }
    
    /// Tests that the `JSONInspector` can access and interpret arrays containing
    /// mixed types such as integers, strings, and date strings.
    ///
    /// - Input:
    ///   ```json
    ///   {
    ///     "values": [1, "two", "1970-01-01T00:00:00Z"]
    ///   }
    ///   ```
    ///
    /// - Verifies:
    ///   - Top-level key count is 1.
    ///   - The array contains the expected values.
    @Test("Handles arrays of mixed primitive values")
    func handlesArrayOfMixedTypes() throws {
        let json = """
        {
            "values": [1, "two", "1970-01-01T00:00:00Z"]
        }
        """

        let parsed = try JSONInspector(json)
        #expect(parsed.topLevelKeyCount == 1)

        let array = try parsed.requireArray("values")
        #expect(array.count == 3)

        #expect(array[0] as? Int == 1)
        #expect(array[1] as? String == "two")
        #expect(array[2] as? String == "1970-01-01T00:00:00Z")
    }
    
    /// Verifies that arrays containing mixed value types are parsed correctly,
    /// and that each element can be inspected individually.
    @Test("Parses arrays of mixed value types")
    func parsesMixedTypeArrays() throws {
        let json = """
        {
            "values": [1, "two", true]
        }
        """

        let parsed = try JSONInspector(json)
        #expect(parsed.topLevelKeyCount == 1)

        let array = try parsed.requireArray("values")
        #expect(array.count == 3)
        #expect(array[0] as? Int == 1)
        #expect(array[1] as? String == "two")
        #expect(array[2] as? Bool == true)
    }
}
