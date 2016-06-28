//
//  Code.swift
//  BSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

/// Represents a string of Javascript code.
public struct Code: Equatable {
    public var code: String
    public var scope: [String:BSON]?

    public init(_ code: String, scope: [String:BSON]? = nil) {
        self.code = code
        self.scope = scope
    }
}

public func ==(lhs: Code, rhs: Code) -> Bool {
    guard lhs.code == rhs.code else {
        return false
    }

    switch (lhs.scope, rhs.scope) {
    case let (lscope?, rscope?) where lscope == rscope:
        return true
    case (.none, .none):
        return true
    default:
        return false
    }
}
