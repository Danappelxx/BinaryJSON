//
//  BSON.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

@_exported import C7
@_exported import CLibbson
import Foundation

/// [Binary JSON](http://bsonspec.org)
public enum BSON {
    case null
    case array([BSON])
    case document([String:BSON])
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case date(NSDate)
    case timestamp(Timestamp)
    case binary(Binary)
    case code(Code)
    case objectID(ObjectID)
    case regularExpression(RegularExpression)
    case key(Key)
}

extension BSON: Equatable {}

public func ==(lhs: BSON, rhs: BSON) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null): return true
    case let (.array(lhs), .array(rhs)): return lhs == rhs
    case let (.document(lhs), .document(rhs)): return lhs == rhs
    case let (.int(lhs), .int(rhs)): return lhs == rhs
    case let (.double(lhs), .double(rhs)): return lhs == rhs
    case let (.bool(lhs), .bool(rhs)): return lhs == rhs
    case let (.string(lhs), .string(rhs)): return lhs == rhs
    case let (.date(lhs), .date(rhs)):
        // Float32 because NSDate is more accurate than MongoDB
        return Float32(lhs.timeIntervalSince1970) == Float32(rhs.timeIntervalSince1970)
    case let (.timestamp(lhs), .timestamp(rhs)): return lhs == rhs
    case let (.binary(lhs), .binary(rhs)): return lhs == rhs
    case let (.code(lhs), .code(rhs)): return lhs == rhs
    case let (.objectID(lhs), .objectID(rhs)): return lhs == rhs
    case let (.regularExpression(lhs), .regularExpression(rhs)): return lhs == rhs
    case let (.key(lhs), .key(rhs)): return lhs == rhs
    default: return false
    }
}

public extension BSON {
    public var arrayValue: [BSON]? {
        return try? get()
    }

    public var documentValue: [String:BSON]? {
        return try? get()
    }

    public var intValue: Int? {
        return try? get()
    }

    public var doubleValue: Double? {
        return try? get()
    }

    public var boolValue: Bool? {
        return try? get()
    }

    public var stringValue: String? {
        return try? get()
    }

    public var dateValue: NSDate? {
        return try? get()
    }

    public var timestampValue: Timestamp? {
        return try? get()
    }

    public var binaryValue: Binary? {
        return try? get()
    }

    public var codeValue: Code? {
        return try? get()
    }

    public var objectIDValue: ObjectID? {
        return try? get()
    }

    public var regularExpressionValue: RegularExpression? {
        return try? get()
    }

    public var keyValue: Key? {
        return try? get()
    }
}

public extension BSON {
    public enum FetchingError: ErrorProtocol {
        case incompatibleType
    }

    public func get<T>() throws -> T {
        switch self {
        case .array(let value as T):
            return value
        case .document(let value as T):
            return value
        case .int(let value as T):
            return value
        case .double(let value as T):
            return value
        case .bool(let value as T):
            return value
        case .string(let value as T):
            return value
        case .date(let value as T):
            return value
        case .timestamp(let value as T):
            return value
        case .binary(let value as T):
            return value
        case .code(let value as T):
            return value
        case .objectID(let value as T):
            return value
        case .regularExpression(let value as T):
            return value
        case .key(let value as T):
            return value
        default:
            throw FetchingError.incompatibleType
        }
    }

    public func get<T>(_ key: String) throws -> T {
        if let value = self[key] {
            return try value.get()
        }

        throw FetchingError.incompatibleType
    }
}

public extension BSON {
    public subscript(index: Int) -> BSON? {
        get {
            guard let array = arrayValue where array.indices ~= index else { return nil }
            return array[index]
        }

        set(bson) {
            guard var array = arrayValue where array.indices ~= index else { return }
            array[index] = bson ?? .null
            self = .array(array)
        }
    }

    public subscript(key: String) -> BSON? {
        get {
            return documentValue?[key]
        }

        set(bson) {
            guard var document = documentValue else { return }
            document[key] = bson
            self = .document(document)
        }
    }
}

public extension BSON {
    public static func infer(_ value: Bool) -> BSON {
        return .bool(value)
    }

    public static func infer(_ value: Double) -> BSON {
        return .double(value)
    }

    public static func infer(_ value: Int) -> BSON {
        return .int(value)
    }

    public static func infer(_ value: String) -> BSON {
        return .string(value)
    }

    public static func infer(_ value: [BSON]) -> BSON {
        return .array(value)
    }

    public static func infer(_ value: [String:BSON]) -> BSON {
        return .document(value)
    }

    public static func infer(_ value: NSDate) -> BSON {
        return .date(value)
    }

    public static func infer(_ value: Timestamp) -> BSON {
        return .timestamp(value)
    }

    public static func infer(_ value: Binary) -> BSON {
        return .binary(value)
    }

    public static func infer(_ value: Code) -> BSON {
        return .code(value)
    }

    public static func infer(_ value: ObjectID) -> BSON {
        return .objectID(value)
    }

    public static func infer(_ value: RegularExpression) -> BSON {
        return .regularExpression(value)
    }

    public static func infer(_ value: BinaryJSON.Key) -> BSON {
        return .key(value)
    }
}

public func ==(lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.time == rhs.time && lhs.ordinal == rhs.ordinal
}

public func ==(lhs: RegularExpression, rhs: RegularExpression) -> Bool {
    return lhs.pattern == rhs.pattern && lhs.options == rhs.options
}
