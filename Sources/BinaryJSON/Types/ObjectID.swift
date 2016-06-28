//
//  ObjectID.swift
//  BSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

import CLibbson

/// BSON Object Identifier.
public struct ObjectID {
    public typealias ByteValue = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    internal var internalValue: bson_oid_t
    public var byteValue: ByteValue {
        get { return self.internalValue.bytes }
        set { self.internalValue.bytes = newValue }
    }

    /// Default initializer.
    ///
    /// Creates a new BSON ObjectID from the specified context, or the default context if none is specified.
    public init(context: Context? = nil) {
        var objectID = bson_oid_t()
        bson_oid_init(&objectID, context?.internalPointer ?? nil)
        self.internalValue = objectID
    }

    public init(byteValue: ByteValue) {
        self.internalValue = bson_oid_t(bytes: byteValue)
    }
}

extension ObjectID: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

extension ObjectID: RawRepresentable {
    public init?(rawValue: String) {
        // must be 24 characters
        guard rawValue.utf8.count == 24 && bson_oid_is_valid(rawValue, rawValue.utf8.count) else {
            return nil
        }

        var objectID = bson_oid_t()
        bson_oid_init_from_string(&objectID, rawValue)
        self.internalValue = objectID
    }
    public var rawValue: String {
        let stringPointer = UnsafeMutablePointer<CChar>(allocatingCapacity:25)

        var objectID = internalValue
        bson_oid_to_string(&objectID, stringPointer)
        return String(cString:stringPointer)
    }
}

extension ObjectID: Hashable {
    public var hashValue: Int {
        var objectID = internalValue
        let hash = bson_oid_hash(&objectID)
        return Int(hash)
    }
}

extension ObjectID: Equatable {}

public func ==(lhs: ObjectID, rhs: ObjectID) -> Bool {
    var oid1 = lhs.internalValue
    var oid2 = rhs.internalValue
    return bson_oid_equal(&oid1, &oid2)
}
