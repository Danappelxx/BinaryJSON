//
//  BSONConvertible.swift
//  BinaryJSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

import Foundation

public protocol BSONRepresentable {
    var bson: BSON { get }
}

public protocol BSONInitializable {
    init(bson: BSON) throws
}

public protocol BSONConvertible: BSONRepresentable, BSONInitializable {}

extension BSON: BSONConvertible {
    public var bson: BSON { return self }

    public init(bson: BSON) throws {
        self = bson
    }
}

extension String: BSONConvertible {
    public var bson: BSON { return .infer(self) }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

extension Int: BSONConvertible {
    public var bson: BSON { return .infer(self) }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

extension Double: BSONConvertible {
    public var bson: BSON { return .infer(self) }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

extension Bool: BSONConvertible {
    public var bson: BSON { return .infer(self) }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

extension Binary: BSONConvertible {
    public var bson: BSON {
        return .infer(self)
    }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

extension ObjectID: BSONConvertible {
    public var bson: BSON {
        return .infer(self)
    }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

extension NSDate: BSONRepresentable {
    public var bson: BSON {
        return .infer(self)
    }

//    public init(bson: BSON) throws {
//        let date: NSDate = try bson.get()
//        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
//    }
}

extension RegularExpression: BSONConvertible {
    public var bson: BSON {
        return .infer(self)
    }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

extension Code: BSONConvertible {
    public var bson: BSON {
        return .infer(self)
    }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

extension Timestamp: BSONConvertible {
    public var bson: BSON {
        return .infer(self)
    }

    public init(bson: BSON) throws {
        self = try bson.get()
    }
}

public extension Collection where Iterator.Element: BSONRepresentable {
    var bson: BSON {
        return .infer(self.map { $0.bson })
    }
}

public extension Dictionary where Key: StringLiteralConvertible, Value: BSONRepresentable {
    var bson: BSON {
        let dict = self
            .mapValues { $0.bson }
            .mapKeys { String($0) }
        return .infer(dict)
    }
}

extension BSON: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self = .infer(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .infer(value)
    }

    public init(stringLiteral value: String) {
        self = .infer(value)
    }
}

extension BSON: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .null
    }
}

extension BSON: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .infer(value)
    }
}

extension BSON: IntegerLiteralConvertible {
    public init(integerLiteral value: Int) {
        self = .infer(value)
    }
}

extension BSON: FloatLiteralConvertible {
    public init(floatLiteral value: Double) {
        self = .infer(value)
    }
}

extension BSON: ArrayLiteralConvertible {
    public init(arrayLiteral elements: BSON...) {
        self = .infer(elements)
    }
}

extension BSON: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, BSON)...) {
        var dictionary = [String:BSON](minimumCapacity: elements.count)

        for pair in elements {
            dictionary[pair.0] = pair.1
        }

        self = .infer(dictionary)
    }
}


public extension Dictionary {
    public func mapValues<T>(_ transform: @noescape (Value) throws -> T) rethrows -> [Key: T] {
        var transformed = [Key:T]()
        for (key, value) in self {
            transformed[key] = try transform(value)
        }
        return transformed
    }
    public func mapKeys<T>(_ transform: @noescape (Key) throws -> T) rethrows -> [T: Value] {
        var transformed = [T:Value]()
        for (key, value) in self {
            try transformed[transform(key)] = value
        }
        return transformed
    }
}
