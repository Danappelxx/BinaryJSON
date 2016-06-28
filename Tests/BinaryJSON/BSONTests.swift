//
//  BSONTests.swift
//  BSONTests
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import XCTest
import BinaryJSON

class BSONTests: XCTestCase {

    func testEquality() {
        let document = sampleDocument()

        for key in document.keys {
            XCTAssertEqual(document[key], document[key])
        }
    }

    func testUnsafePointer() throws {

        let document = sampleDocument()

        // create from pointer
        do {

            let container = try AutoReleasingBSONContainer(document: document)
            let newDocument = container.retrieveDocument()

            for key in document.keys {
                XCTAssertEqual(document[key], newDocument[key])
            }
        }

        // try to create a 2nd time, to make sure we didnt modify the unsafe pointer
        do {

            let container = try AutoReleasingBSONContainer(document: document)
            let newDocument = container.retrieveDocument()

            for key in document.keys {
                XCTAssertEqual(document[key], newDocument[key])
            }
        }
    }

    func testConvertible() {
        let document: [String:BSON] = [
            "string": "string",
            "int": 5,
            "double": 5.123,
            "bool": true,
            "arr": [1,2,3],
            "dict": [
                "key1": "value1",
                "key2": [1,2,3]
            ]
        ]

        XCTAssert(document["string"]?.stringValue == "string")
        XCTAssert(document["int"]?.intValue == 5)
        XCTAssert(document["double"]?.doubleValue == 5.123)
        XCTAssert(document["bool"]?.boolValue == true)
        XCTAssert(document["arr"]!.arrayValue! == [1,2,3])
        XCTAssert(document["dict"]!.documentValue! == ["key1": "value1", "key2": [1,2,3]])
    }

//    func testJSON() throws {
//        let document: [String:BSON] = [
//            "string": "string",
//            "int": 5,
//            "double": 5.123,
//            "bool": true,
//            "arr": [1,2,3],
//            "dict": [
//                "key1": "value1",
//                "key2": [1,2,3]
//            ]
//        ]
//
//        let json = toJSONString(document)
//
//        // lazy checking
//        XCTAssert(json.characters.count > 0)
//
//        let documentFromJSON = try fromJSONString(json)
//
//        XCTAssertEqual(document, documentFromJSON)
//    }
}

extension BSONTests {
    static var allTests: [(String, (BSONTests) -> () throws -> Void)] {
        return [
            ("testUnsafePointer", testUnsafePointer),
            ("testConvertible", testConvertible),
//            ("testJSON", testJSON)
        ]
    }
}


// MARK: - Internal

func sampleDocument() -> [String:BSON] {

    var document = [String:BSON]()

    // build BSON document
    do {
        var numbersDocument = [String:BSON]()

        numbersDocument["double"] = 1000.1111
        numbersDocument["int"] = 32
        document["numbersDocument"] = .infer(numbersDocument)
        document["string"] = "Text"
        document["array"] = [["key": ["subarray string"]]]
        document["objectID"] = .infer(ObjectID())
        document["data"] = .infer(Binary(data: Data([] + "test".utf8)))
        document["null"] = .null
        document["regex"] = .infer(RegularExpression(pattern: "pattern", options: ""))
        document["code"] = .infer(Code("js code"))
        document["code with scope"] = .infer(Code("JS code", scope: ["myVariable": "value"]))
        document["date"] = .infer(NSDate())
        document["timestamp"] = .infer(Timestamp(time: 10, ordinal: 1))
        document["minkey"] = .infer(Key.min)
        document["maxkey"] = .infer(Key.max)
    }

    return document
}
