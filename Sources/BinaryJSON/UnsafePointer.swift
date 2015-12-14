//
//  UnsafePointer.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX)
    import bson
#elseif os(Linux)
    import CBSON
#endif

public extension BSON {
    
    /// Creates an unsafe pointer of a BSON document for use with the C API.
    ///
    /// Make sure to use ```bson_destroy``` clean up the allocated BSON document.
    static func unsafePointerFromDocument(document: BSON.Document) -> UnsafeMutablePointer<bson_t>? {
        
        let documentPointer = bson_new()
        
        for (key, value) in document {
            
            guard appendValue(documentPointer, key: key, value: value) == true
                else { return nil }
        }
        
        return documentPointer
    }
}

private extension BSON {
    
    static func appendValue(documentPointer: UnsafeMutablePointer<bson_t>, key: String, value: BSON.Value) -> Bool {
        
        let keyLength = Int32(key.utf8.count)
        
        switch value {
            
        case .Null:
            
            return bson_append_null(documentPointer, key, keyLength)
            
        case let .String(string):
            
            let stringLength = Int32(string.utf8.count)
            
            return bson_append_utf8(documentPointer, key, keyLength, string, stringLength)
            
        case let .Number(number):
            
            switch number {
            case let .Boolean(value): return bson_append_bool(documentPointer, key, keyLength, value)
            case let .Integer32(value): return bson_append_int32(documentPointer, key, keyLength, value)
            case let .Integer64(value): return bson_append_int64(documentPointer, key, keyLength, value)
            case let .Double(value): return bson_append_double(documentPointer, key, keyLength, value)
            }
            
        case let .Date(date):
            
            let secondsSince1970 = Int64(date.timeIntervalSince1970)
            
            return bson_append_date_time(documentPointer, key, keyLength, secondsSince1970)
            
        case let .Data(data):
            
            // TODO: Implement Binary Data
            break
            
        case let .Document(childDocument):
            
            let childDocumentPointer = UnsafeMutablePointer<bson_t>()
            
            guard bson_append_document_begin(documentPointer, key, keyLength, childDocumentPointer)
                else { return false }
        
            for (childKey, childValue) in childDocument {
                
                guard appendValue(childDocumentPointer, key: childKey, value: childValue)
                    else { return false }
            }
            
            guard bson_append_document_end(documentPointer, childDocumentPointer)
                else { return false }
            
        case let .Array(array):
            
            let childPointer = UnsafeMutablePointer<bson_t>()
            
            bson_append_array_begin(documentPointer, key, keyLength, childPointer)
            
            for (index, subvalue) in array.enumerate() {
                
                let indexKey = "\(index)"
                
                appendValue(childPointer, key: indexKey, value: subvalue)
            }
            
            bson_append_array_end(documentPointer, childPointer)
        }

    }
}



