//
//  BSONTests.swift
//  BSONTests
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import XCTest
import BinaryJSON
import CBSON

class BSONTests: XCTestCase {
    
    var allTests : [(String, () -> Void)] {
        return [
            ("testUnsafePointer", testUnsafePointer),
        ]
    }
    
    func testUnsafePointer() {
        
        let document = sampleDocument()
        
        // create from pointer
        do {
            
            print("Document: \n\(document)\n")
            
            guard let unsafePointer = BSON.unsafePointerFromDocument(document)
                else { XCTFail("Could not create unsafe pointer"); return }
            
            defer { bson_destroy(unsafePointer) }
            
            guard let newDocument = BSON.documentFromUnsafePointer(unsafePointer)
                else { XCTFail("Could not create document from unsafe pointer"); return }
            
            print("New Document: \n\(document)\n")
            
            XCTAssert(newDocument == document, "\(newDocument) == \(document)")
        }
        
        // try to create a 2nd time, to make sure we didnt modify the unsafe pointer
        do {
            
            guard let unsafePointer = BSON.unsafePointerFromDocument(document)
                else { XCTFail("Could not create unsafe pointer"); return }
            
            defer { bson_destroy(unsafePointer) }
            
            guard let newDocument = BSON.documentFromUnsafePointer(unsafePointer)
                else { XCTFail("Could not create document from unsafe pointer"); return }
            
            XCTAssert(newDocument == document, "\(newDocument) == \(document)")
        }
    }
}

// MARK: - Internal

func sampleDocument() -> BSON.Document {
    
    let time = TimeInterval(Int(TimeIntervalSince1970()))
    
    // Date is more precise than supported by BSON, so equality fails
    let date = Date(timeIntervalSince1970: time)
    
    var document = BSON.Document()
    
    // build BSON document
    do {
        
        var numbersDocument = BSON.Document()
        
        numbersDocument["double"] = .Number(.Double(1000.1111))
        
        numbersDocument["int32"] = .Number(.Integer32(32))
        
        numbersDocument["int64"] = .Number(.Integer64(64))
        
        document["numbersDocument"] = .Document(numbersDocument)
        
        document["string"] = .String("Text")
        
        document["array"] = .Array([.Document(["key": .Array([.String("subarray string")])])])
        
        document["objectID"] = .ObjectID(BSON.ObjectID())
        
        document["data"] = .Binary(BSON.Binary(data: Data(byteValue: [] + "test".utf8)))
        
        document["datetime"] = .Date(date)
        
        document["null"] = .Null
        
        document["regex"] = .RegularExpression(BSON.RegularExpression("pattern", options: ""))
        
        document["code"] = .Code(BSON.Code("js code"))
        
        document["code with scope"] = .Code(BSON.Code("JS code", scope: ["myVariable": .String("value")]))
        
        document["timestamp"] = .Timestamp(BSON.Timestamp(time: 10, oridinal: 1))
        
        document["minkey"] = .Key(.Minimum)
        
        document["maxkey"] = .Key(.Maximum)
    }
    
    return document
}

extension String {
    func toUTF8Data() -> Data {
        
        return Data(byteValue: [] + utf8)
    }
}