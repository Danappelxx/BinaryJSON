//
//  BSON.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation

/// [Binary JSON](http://bsonspec.org)
public struct BSON {
    
    /// BSON Array
    public typealias Array = [BSON.Value]
    
    /// BSON Document
    public typealias Document = [String: BSON.Value]
    
    /// BSON value type. 
    public enum Value: RawRepresentable, Equatable, CustomStringConvertible {
        
        case Null
        
        case Array(BSON.Array)
        
        case Document(BSON.Document)
        
        case Number(BSON.Number)
        
        case String(StringValue)
        
        case Date(DateValue)
        
        case Timestamp(BSON.Timestamp)
        
        case Binary(BSON.Binary)
        
        case Code(BSON.Code)
        
        case ObjectID(BSON.ObjectID)
        
        case RegularExpression(BSON.RegularExpression)
        
        case Key(BSON.Key)
        
        // MARK: - Extract Values
        
        /// Tries to extract an array value from a ```BSON.Value```.
        ///
        /// - Note: Does not convert the individual elements of the array to their raw values.
        public var arrayValue: BSON.Array? {
            
            switch self {
            case let .Array(value): return value
            default: return nil
            }
        }
        
        /// Tries to extract a document value from a ```BSON.Value```.
        ///
        /// - Note: Does not convert the values of the document to their raw values.
        public var documentValue: BSON.Document? {
            
            switch self {
            case let .Document(value): return value
            default: return nil
            }
        }
    }
    
    public enum Number {
        
        case Boolean(Bool)
        
        case Integer32(Int32)
        
        case Integer64(Int64)
        
        case Double(DoubleValue)
    }
    
    public struct Binary {
        
        public enum Subtype {
            
            case Generic
            case Function
            case Old
            case UUID
            case UUIDOld
            case MD5
            case User
        }
        
        public var data: Data
        
        public var subtype: Subtype
        
        public init(data: Data, subtype: Subtype = .Generic) {
            
            self.data = data
            self.subtype = subtype
        }
    }
    
    /// Represents a string of Javascript code.
    public struct Code {
        
        public var code: String
        
        public var scope: BSON.Document?
        
        public init(code: String, scope: BSON.Document? = nil) {
            
            self.code = code
            self.scope = scope
        }
    }
    
    public enum Key {
        
        case Minimum
        case Maximum
    }
        
    public struct Timestamp {
        
        /// Seconds since the Unix epoch
        public var time: UInt32
        
        /// Prdinal for operations within a given second
        public var oridinal: UInt32
        
        public init(time: UInt32, oridinal: UInt32) {
            
            self.time = time
            self.oridinal = oridinal
        }
    }
    
    public struct RegularExpression {
        
        public var pattern: String
        
        public var options: String
        
        public init(_ pattern: String, options: String) {
            
            self.pattern = pattern
            self.options = options
        }
    }
}

// MARK: - RawRepresentable

public extension BSON.Value {
    
    var rawValue: Any {
        
        switch self {
            
        case .Null: return SwiftFoundation.Null()
            
        case let .Array(array):
            
            let rawValues = array.map { (value) in return value.rawValue }
            
            return rawValues
            
        case let .Document(document):
            
            var rawObject = [StringValue: Any]()
            
            for (key, value) in document {
                
                rawObject[key] = value.rawValue
            }
            
            return rawObject
            
        case let .Number(number): return number.rawValue
            
        case let .Date(date): return date
            
        case let .Timestamp(timestamp): return timestamp
            
        case let .Binary(binary): return binary
            
        case let .String(string): return string
            
        case let .Key(key): return key
            
        case let .Code(code): return code
            
        case let .ObjectID(objectID): return objectID
            
        case let .RegularExpression(regularExpression): return regularExpression
        }
    }
    
    init?(rawValue: Any) {
        
        guard (rawValue as? SwiftFoundation.Null) == nil else {
            
            self = .Null
            return
        }
        
        if let key = rawValue as? BSON.Key {
            
            self = .Key(key)
            return
        }
        
        if let string = rawValue as? Swift.String {
            
            self = .String(string)
            return
        }
        
        if let date = rawValue as? SwiftFoundation.Date {
            
            self = .Date(date)
            return
        }
        
        if let timestamp = rawValue as? BSON.Timestamp {
            
            self = .Timestamp(timestamp)
            return
        }
        
        if let binary = rawValue as? BSON.Binary {
            
            self = .Binary(binary)
            return
        }
        
        if let number = BSON.Number(rawValue: rawValue) {
            
            self = .Number(number)
            return
        }
        
        if let rawArray = rawValue as? [Any], let jsonArray: [BSON.Value] = BSON.Value.fromRawValues(rawArray) {
            
            self = .Array(jsonArray)
            return
        }
        
        if let rawDictionary = rawValue as? [Swift.String: Any] {
            
            var document = BSON.Document()
            
            for (key, rawValue) in rawDictionary {
                
                guard let bsonValue = BSON.Value(rawValue: rawValue) else { return nil }
                
                document[key] = bsonValue
            }
            
            self = .Document(document)
            return
        }
        
        if let code = rawValue as? BSON.Code {
            
            self = .Code(code)
            return
        }
        
        if let objectID = rawValue as? BSON.ObjectID {
            
            self = .ObjectID(objectID)
            return
        }
        
        if let regularExpression = rawValue as? BSON.RegularExpression {
            
            self = .RegularExpression(regularExpression)
            return
        }
        
        return nil
    }
}

public extension BSON.Number {
    
    public var rawValue: Any {
        
        switch self {
        case .Boolean(let value): return value
        case .Integer32(let value): return value
        case .Integer64(let value): return value
        case .Double(let value):  return value
        }
    }
    
    public init?(rawValue: Any) {
        
        if let value = rawValue as? Bool            { self = .Boolean(value) }
        if let value = rawValue as? Int32           { self = .Integer32(value) }
        if let value = rawValue as? Int64           { self = .Integer64(value) }
        if let value = rawValue as? DoubleValue     { self = .Double(value)  }
        
        return nil
    }
}

// MARK: - CustomStringConvertible

public extension BSON.Value {
    
    public var description: Swift.String { return "\(rawValue)" }
}

public extension BSON.Number {
    
    public var description: Swift.String { return "\(rawValue)" }
}

// MARK: Equatable

public func ==(lhs: BSON.Value, rhs: BSON.Value) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.Null, .Null): return true
        
    case let (.String(leftValue), .String(rightValue)): return leftValue == rightValue
        
    case let (.Number(leftValue), .Number(rightValue)): return leftValue == rightValue
        
    case let (.Array(leftValue), .Array(rightValue)): return leftValue == rightValue
        
    case let (.Document(leftValue), .Document(rightValue)): return leftValue == rightValue
        
    default: return false
    }
}

public func ==(lhs: BSON.Number, rhs: BSON.Number) -> Bool {
    
    switch (lhs, rhs) {
        
    case let (.Boolean(leftValue), .Boolean(rightValue)): return leftValue == rightValue
        
    case let (.Integer32(leftValue), .Integer32(rightValue)): return leftValue == rightValue
        
    case let (.Integer64(leftValue), .Integer64(rightValue)): return leftValue == rightValue
        
    case let (.Double(leftValue), .Double(rightValue)): return leftValue == rightValue
        
    default: return false
    }
}

// MARK: - Typealiases

// Due to compiler error

public typealias DataValue = Data

public typealias DateValue = Date



