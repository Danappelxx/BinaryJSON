//
//  Appender.swift
//  BinaryJSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

import CLibbson

public final class Appender {
    public struct OverflowError: ErrorProtocol {}

    let container: BSONPointerContainer
    public init(container: BSONPointerContainer) {
        self.container = container
    }

    public func append(key: String, value: BSON) throws {
        let keyLength = Int32(key.utf8.count)

        // to reduce boilerplate a little, we need to have a little boilerplate
        func append0(_ f: (UnsafeMutablePointer<bson_t>, UnsafePointer<Int8>, Int32) -> Bool) throws {
            guard f(self.container.pointer, key, keyLength) else {
                throw OverflowError()
            }
        }
        func append1<T>(_ f: (UnsafeMutablePointer<bson_t>, UnsafePointer<Int8>, Int32, T) -> Bool, _ t: T) throws {
            guard f(self.container.pointer, key, keyLength, t) else {
                throw OverflowError()
            }
        }
        func append2<T, U>(_ f: (UnsafeMutablePointer<bson_t>, UnsafePointer<Int8>, Int32, T, U) -> Bool, _ t: T, _ u: U) throws {
            guard f(self.container.pointer, key, keyLength, t, u) else {
                throw OverflowError()
            }
        }
        func append3<T, U, V>(_ f: (UnsafeMutablePointer<bson_t>, UnsafePointer<Int8>, Int32, T, U, V) -> Bool, _ t: T, _ u: U, _ v: V) throws {
            guard f(self.container.pointer, key, keyLength, t, u, v) else {
                throw OverflowError()
            }
        }

        switch value {

        case .null:
            try append0(bson_append_null)

        case let .string(string):
            try append2(bson_append_utf8, string, Int32(string.utf8.count))

        case let .bool(value):
            try append1(bson_append_bool, value)

        case let .int(value):
            // TODO: Don't make assumptions about 64bit
            try append1(bson_append_int64, Int64(value))

        case let .double(value):
            try append1(bson_append_double, value)

        case let .date(date):
            var time = timeval(timeInterval: date.timeIntervalSince1970)
            try append1(bson_append_timeval, &time)

        case let .timestamp(timestamp):
            try append2(bson_append_timestamp, timestamp.time, timestamp.ordinal)

        case let .binary(binary):
            try append3(bson_append_binary, binary.subtype.cValue, binary.data.bytes, UInt32(binary.data.bytes.count))

        case let .regularExpression(regex):
            try append2(bson_append_regex, regex.pattern, regex.options)

        case let .key(keyType):
            switch keyType {
            case .max:
                try append0(bson_append_maxkey)
            case .min:
                try append0(bson_append_minkey)
            }

        case let .code(code):
            switch code.scope {
            case .some(let scope):
                try append2(bson_append_code_with_scope, code.code, AutoReleasingBSONContainer(document: scope).pointer)
            case .none:
                try append1(bson_append_code, code.code)
            }

        case let .objectID(objectID):
            var value = objectID.internalValue
            try append1(bson_append_oid, &value)

        case let .document(childDocument):

            let childContainer = AutoReleasingBSONContainer()

            try append1(bson_append_document_begin, childContainer.pointer)

            let childappend = Appender(container: childContainer)
            try childDocument.forEach(childappend.append)

            guard bson_append_document_end(container.pointer, childContainer.pointer) else {
                throw OverflowError()
            }

        case let .array(array):

            let childContainer = AutoReleasingBSONContainer()

            try append1(bson_append_array_begin, childContainer.pointer)

            let childappend = Appender(container: childContainer)
            try array.enumerated().forEach { try childappend.append(key: "\($0)", value: $1) }

            guard bson_append_array_end(container.pointer, childContainer.pointer) else {
                throw OverflowError()
            }
        }
    }
}
