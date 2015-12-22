//
//  BSONTests.swift
//  BSONTests
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX)
    import bson
#elseif os(Linux)
    import CBSON
#endif

import XCTest
import BinaryJSON
import SwiftFoundation

class BSONTests: XCTestCase {
    
    func testUnsafePoiner() {
        
        var document = BSON.Document()
        
        // build BSON document
        do {
            
            var numbersDocument = BSON.Document()
            
            numbersDocument["double"] = .Number(.Double(1000.111))
            
            numbersDocument["int32"] = .Number(.Integer32(1000))
            
            numbersDocument["int64"] = .Number(.Integer64(1000))
            
            document["numbersDocument"] = .Document(numbersDocument)
            
            //document["string"] = .String("Text")
            
            //document["array"]
            
            document["objectID"] = .ObjectID(BSON.ObjectID())
            
            document["datetime"] = .Date(Date())
            
            document["null"] = .Null
            
            //document["regex"] = .RegularExpression(BSON.RegularExpression("pattern", options: "\\w"))
            
            document["code"] = .Code(BSON.Code("js code"))
            
            //document["code with scope"] = .Code(BSON.Code("JS code", scope: ["myVariable": .String("value")]))
            
            document["timestamp"] = .Timestamp(BSON.Timestamp(time: 10, oridinal: 1))
            
            document["minkey"] = .Key(.Minimum)
            
            document["maxkey"] = .Key(.Maximum)
        }
        
        print("Document: \n\(document)")
        
        guard let unsafePointer = BSON.unsafePointerFromDocument(document)
            else { XCTFail("Could not create unsafe pointer"); return }
        
        defer { bson_destroy(unsafePointer) }
        
        guard let newDocument = BSON.documentFromUnsafePointer(unsafePointer)
            else { XCTFail("Could not create document from unsafe pointer"); return }
        
        print("New Document: \n\(document)")
        
        XCTAssert(newDocument == document, "\(newDocument) == \(document)")
    }
    
}
