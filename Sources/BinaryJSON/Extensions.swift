//
//  Extensions.swift
//  BinaryJSON
//
//  Created by Alsey Coleman Miller on 12/15/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

// MARK: - Protocol

/// Type can be converted to BSON.
public protocol BSONEncodable {
    
    /// Encodes the reciever into BSON.
    func toBSON() -> BSON.Value
}

/// Type can be converted from BSON.
public protocol BSONDecodable {
    
    /// Decodes the reciever from BSON.
    init?(BSONValue: BSON.Value)
}

// MARK: - Swift Standard Library Types

// MARK: Encodable

extension String: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .String(self) }
}

extension String: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? String else { return nil }
        
        self = value
    }
}

extension Int32: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Number(.Integer32(self)) }
}

extension Int32: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Int32 else { return nil }
        
        self = value
    }
}

extension Int64: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Number(.Integer64(self)) }
}

extension Int64: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Int64 else { return nil }
        
        self = value
    }
}

extension Double: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Number(.Double(self)) }
}

extension Double: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Double else { return nil }
        
        self = value
    }
}

extension Bool: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Number(.Boolean(self)) }
}

extension Bool: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Bool else { return nil }
        
        self = value
    }
}

// MARK: - Collection Extensions

// MARK: Encodable

public extension Collection where Iterator.Element: BSONEncodable {
    
    func toBSON() -> BSON.Value {
        
        var BSONArray = BSON.Array()
        
        for BSONEncodable in self {
            
            let BSONValue = BSONEncodable.toBSON()
            
            BSONArray.append(BSONValue)
        }
        
        return .Array(BSONArray)
    }
}

public extension Dictionary where Value: BSONEncodable, Key: StringLiteralConvertible {
    
    /// Encodes the reciever into BSON.
    func toBSON() -> BSON.Value {
        
        var document = BSON.Document()
        
        for (key, value) in self {
            
            let BSONValue = value.toBSON()
            
            let keyString = String(key)
            
            document[keyString] = BSONValue
        }
        
        return .Document(document)
    }
}

// MARK: Decodable

public extension BSONDecodable {
    
    /// Decodes from an array of BSON values.
    static func fromBSON(BSONArray: BSON.Array) -> [Self]? {
        
        var BSONDecodables = [Self]()
        
        for BSONValue in BSONArray {
            
            guard let BSONDecodable = self.init(BSONValue: BSONValue) else { return nil }
            
            BSONDecodables.append(BSONDecodable)
        }
        
        return BSONDecodables
    }
}

// MARK: - RawRepresentable Extensions

// MARK: Encode

public extension RawRepresentable where RawValue: BSONEncodable {
    
    /// Encodes the reciever into BSON.
    func toBSON() -> BSON.Value {
        
        return rawValue.toBSON()
    }
}

// MARK: Decode

public extension RawRepresentable where RawValue: BSONDecodable {
    
    /// Decodes the reciever from BSON.
    init?(BSONValue: BSON.Value) {
        
        guard let rawValue = RawValue(BSONValue: BSONValue) else { return nil }
        
        self.init(rawValue: rawValue)
    }
}

// MARK: Literals

extension BSON.Value: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: Swift.String) {
        self = .String(value)
    }

    public init(extendedGraphemeClusterLiteral value: Swift.String) {
        self = .String(value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self = .String(value)
    }
}

extension BSON.Value: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .Null
    }
}

extension BSON.Value: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .Number(.Boolean(value))
    }
}

extension BSON.Value: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Number(.Integer32(Int32(value)))
    }
}

extension BSON.Value: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .Number(.Double(Double(value)))
    }
}

extension BSON.Value: ArrayLiteralConvertible {
    public init(arrayLiteral elements: BSON.Value...) {
        self = .Array(elements)
    }
}

extension BSON.Value: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (Swift.String, BSON.Value)...) {
        var dictionary = Dictionary<Swift.String, BSON.Value>(minimumCapacity: elements.count)

        for pair in elements {
            dictionary[pair.0] = pair.1
        }

        self = .Document(dictionary)
    }
}
