//
//  Iterator.swift
//  BinaryJSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

import Foundation
import CLibbson

public final class Iterator: IteratorProtocol {
    let pointer: UnsafeMutablePointer<bson_iter_t>

    init(pointer: UnsafeMutablePointer<bson_iter_t>) {
        self.pointer = pointer
    }

    convenience init() {
        self.init(pointer: UnsafeMutablePointer(allocatingCapacity: 1))
    }

    convenience init(documentPointer: UnsafeMutablePointer<bson_t>) {
        self.init()
        bson_iter_init(self.pointer, documentPointer)
    }

    deinit {
        self.pointer.deallocateCapacity(1)
    }

    public func makeDocument() -> [String:BSON] {
        var document = [String:BSON]()
        while let (key, value) = self.next() {
            document[key] = value
        }
        return document
    }

    public func next() -> (String, BSON)? {
        guard bson_iter_next(pointer) else {
            return nil
        }
        return nextPair()
    }

    private func nextPair() -> (String, BSON)? {

        let key = String(validatingUTF8: bson_iter_key(pointer))!

        let type = bson_iter_type(pointer)

        switch bson_iter_type(pointer) {

        case BSON_TYPE_DOUBLE:
            let value = bson_iter_double(pointer)
            return (key, value.bson)

        case BSON_TYPE_UTF8:
            let value = String(validatingUTF8: bson_iter_utf8(pointer, nil))!
            return (key, value.bson)

        case BSON_TYPE_DOCUMENT:
            let childPointer = UnsafeMutablePointer<bson_iter_t>(allocatingCapacity: 1)
            // TODO: error handling
            bson_iter_recurse(pointer, childPointer)

            let childIterator = Iterator(pointer: childPointer)

            return (key, childIterator.makeDocument().bson)

        case BSON_TYPE_ARRAY:
            let childPointer = UnsafeMutablePointer<bson_iter_t>(allocatingCapacity: 1)
            // TODO: error handling
            bson_iter_recurse(pointer, childPointer)

            let childIterator = Iterator(pointer: childPointer)
            let childDocument = childIterator.makeDocument()

            return (key, childDocument.map { $1 }.bson)

        case BSON_TYPE_BINARY:

            let subtypePointer = UnsafeMutablePointer<bson_subtype_t>(allocatingCapacity: 1)
            defer { subtypePointer.deallocateCapacity(1) }

            let lengthPointer = UnsafeMutablePointer<UInt32>(allocatingCapacity: 1)
            defer { lengthPointer.deallocateCapacity(1) }

            let bufferPointer = UnsafeMutablePointer<UnsafePointer<UInt8>?>(allocatingCapacity: 1)
            defer { bufferPointer.deallocateCapacity(1) }

            bson_iter_binary(pointer, subtypePointer, lengthPointer, bufferPointer)

            var bytes = [UInt8](repeating: 0, count: Int(lengthPointer.pointee))

            memcpy(&bytes, bufferPointer.pointee, Int(lengthPointer.pointee))

            let binary = Binary(
                data: C7.Data(bytes),
                subtype: Binary.Subtype(cValue: subtypePointer.pointee)
            )

            return (key, binary.bson)

        // deprecated, no bindings
        case BSON_TYPE_DBPOINTER, BSON_TYPE_UNDEFINED, BSON_TYPE_SYMBOL:
            fatalError("Using deprecated BSON types")

        case BSON_TYPE_OID:
            // should not be freed
            // safe to unwrap
            let oidPointer = bson_iter_oid(pointer)!
            let objectID = ObjectID(byteValue: oidPointer.pointee.bytes)
            return (key, objectID.bson)

        case BSON_TYPE_BOOL:
            let bool = bson_iter_bool(pointer)
            return (key, bool.bson)

        case BSON_TYPE_DATE_TIME:
            let timePointer = UnsafeMutablePointer<timeval>(allocatingCapacity: 1)
            defer { timePointer.deallocateCapacity(1) }

            bson_iter_timeval(pointer, timePointer)

            let date = NSDate(timeIntervalSince1970: timePointer.pointee.TimeIntervalValue)

            return (key, date.bson)

        case BSON_TYPE_NULL:
            return (key, .null)

        case BSON_TYPE_REGEX:
            let optionsBufferPointer = UnsafeMutablePointer<UnsafePointer<CChar>?>(allocatingCapacity:1)
            defer { optionsBufferPointer.deallocateCapacity(1) }

            // safe to unwrap
            let patternBuffer = bson_iter_regex(pointer, optionsBufferPointer)!

            // TODO: Make sure this is correct (maybe its an array of buffers?)
            // https://github.com/mongodb/libbson/blob/master/src/bson/bson-iter.c#L1113
            let optionsBuffer = optionsBufferPointer.pointee!

            let options = String(validatingUTF8: optionsBuffer)!
            let pattern = String(validatingUTF8: patternBuffer)!
            let regex = RegularExpression(pattern: pattern, options: options)

            return (key, regex.bson)

        case BSON_TYPE_CODE:
            let buffer = bson_iter_code(pointer, nil)!
            let codeString = String(validatingUTF8: buffer)!
            let code = Code(codeString)

            return (key, code.bson)

        case BSON_TYPE_CODEWSCOPE:

            let scopeLengthPointer = UnsafeMutablePointer<UInt32>(allocatingCapacity: 1)
            defer { scopeLengthPointer.deallocateCapacity(1) }
            let scopeBuffer = UnsafeMutablePointer<UnsafePointer<UInt8>?>(allocatingCapacity:1)
            defer { scopeBuffer.deallocateCapacity(1) }

            let buffer = bson_iter_codewscope(pointer, nil, scopeLengthPointer, scopeBuffer)!
            let codeString = String(validatingUTF8: buffer)!

            let bsonPointer = bson_new()
            // TODO: Error handling
            bson_init_static(bsonPointer, scopeBuffer.pointee, Int(scopeLengthPointer.pointee))

            let scopeContainer = AutoReleasingBSONContainer(bson: bsonPointer!)
            let scopeDocument = scopeContainer.retrieveDocument()

            let code = Code(codeString, scope: scopeDocument)

            return (key, code.bson)

        case BSON_TYPE_INT32:
            let int = bson_iter_int32(pointer)
            return (key, Int(int).bson)

        case BSON_TYPE_INT64:
            let int = bson_iter_int64(pointer)
            return (key, Int(int).bson)

        case BSON_TYPE_TIMESTAMP:
            let timePointer = UnsafeMutablePointer<UInt32>(allocatingCapacity: 1)
            defer { timePointer.deallocateCapacity(1) }
            let incrementPointer = UnsafeMutablePointer<UInt32>(allocatingCapacity: 1)
            defer { incrementPointer.deallocateCapacity(1) }

            bson_iter_timestamp(pointer, timePointer, incrementPointer)

            let timestamp = Timestamp(time: timePointer.pointee, ordinal: incrementPointer.pointee)
            return (key, timestamp.bson)

        case BSON_TYPE_MAXKEY:
            return (key, .key(.max))

        case BSON_TYPE_MINKEY:
            return (key, .key(.min))

        default: fatalError("\(type) not implemented")
        }
    }
}
