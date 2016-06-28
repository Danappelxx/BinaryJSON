//
//  Reader.swift
//  BinaryJSON
//
//  Created by Alsey Coleman Miller on 12/20/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import CLibbson

public final class Reader: IteratorProtocol {

    private let internalPointer: UnsafeMutablePointer<bson_reader_t>

    public init(data: Data) {
        self.internalPointer = bson_reader_new_from_data(data.bytes, data.bytes.count)
    }

    deinit {
        bson_reader_destroy(internalPointer)
    }

    public func next() -> [String:BSON]? {
        var eof = false

        guard let valuePointer = bson_reader_read(internalPointer, &eof) else {
            return nil
        }

        let container = AutoReleasingBSONContainer(bson: UnsafeMutablePointer(valuePointer))
        return container.retrieveDocument()
    }
}
