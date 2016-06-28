//
//  Timestamp.swift
//  BSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

public struct Timestamp: Equatable {

    /// Seconds since the Unix epoch.
    public var time: UInt32
    /// Ordinal for operations within a given second.
    public var ordinal: UInt32

    public init(time: UInt32, ordinal: UInt32) {
        self.time = time
        self.ordinal = ordinal
    }
}
