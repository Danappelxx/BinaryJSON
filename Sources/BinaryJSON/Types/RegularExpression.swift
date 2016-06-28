//
//  RegularExpression.swift
//  BSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

public struct RegularExpression: Equatable {

    public var pattern: String
    public var options: String

    public init(pattern: String, options: String) {
        self.pattern = pattern
        self.options = options
    }
}
