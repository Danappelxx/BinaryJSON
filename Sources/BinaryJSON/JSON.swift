//
//  JSONEncodable.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import CLibbson

//// MARK: - JSON String
//
//public extension BSON {
//    
//    /// Converts the BSON document to JSON.
//    static func toJSONString(document: [String:BSON]) -> String {
//        
//       guard let pointer = unsafePointerFromDocument(document)
//            else { fatalError("Could not convert document to unsafe pointer") }
//        
//        defer { bson_destroy(pointer) }
//        
//        return toJSONString(pointer)
//    }
//    
//    /// Converts the BSON pointer to JSON.
//    static func toJSONString(unsafePointer: UnsafePointer<bson_t>) -> String {
//        
//        var length = 0
//        
//        let stringBuffer = bson_as_json(unsafePointer, &length)
//        
//        defer { bson_free(stringBuffer) }
//        
//        let string = String(cString:stringBuffer)
//        
//        return string
//    }
//
//    static func pointerFromJSONString(json: String) throws -> UnsafeMutablePointer<bson_t> {
//
//        var error = bson_error_t()
//        let bson = bson_new_from_json(json, -1, &error)
//
//        guard error.code == 0 else {
//            throw Error(unsafePointer: &error)
//        }
//
//        return bson
//    }
//
//    static func fromJSONString(json: String) throws -> [String:BSON] {
//
//        let bson = try pointerFromJSONString(json)
//
//        let document = [String:BSON]FromUnsafePointer(bson)
//
//        // if bson_new_from_json succeeded, we can guarantee this works
//        return document!
//    }
//}
