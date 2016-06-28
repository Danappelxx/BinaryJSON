//
//  BSONPointerContainer.swift
//  BinaryJSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

import CLibbson

public protocol BSONPointerContainer {
    init(bson: UnsafeMutablePointer<bson_t>)
    var pointer: UnsafeMutablePointer<bson_t> {get}
}

public extension BSONPointerContainer {
    init() {
        self.init(bson: bson_new())
    }

    init(document: [String:BSON]) throws {
        self.init()
        let appender = Appender(container: self)
        try document.forEach(appender.append)
    }

    init(array: [BSON]) throws {
        self.init()
        let appender = Appender(container: self)
        try array.enumerated().forEach { try appender.append(key: "\($0)", value: $1) }
    }

    /// Get underlying document
    public func retrieveDocument() -> [String:BSON] {
        let iterator = Iterator(documentPointer: self.pointer)
        return iterator.makeDocument()
    }
}

/// Carries an UnsafeMutablePointer<bson_t> and calls `bson_destroy` on it upon deinitialization.
public final class AutoReleasingBSONContainer: BSONPointerContainer {
    public let pointer: UnsafeMutablePointer<bson_t>

    public init(bson: UnsafeMutablePointer<bson_t>) {
        self.pointer = bson
    }

    deinit {
        bson_destroy(self.pointer)
    }
}
