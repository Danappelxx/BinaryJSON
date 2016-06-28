//
//  POSIXTime.swift
//  SwiftFoundation
//
//  Created by Alsey Coleman Miller on 7/19/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import Foundation
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin.C
#elseif os(Linux)
    import Glibc
#endif

public extension timeval {

    static func timeOfDay() throws -> timeval {

        var timeStamp = timeval()

        guard gettimeofday(&timeStamp, nil) == 0 else {

            if let error = POSIXError.fromErrorNumber as? ErrorProtocol {
                throw error
            } else {
                fatalError("Make an issue if this hits - fixing this is a TODO but I may forget")
            }
        }

        return timeStamp
    }

    init(timeInterval: TimeInterval) {

        let (integerValue, decimalValue) = modf(timeInterval)

        let million: TimeInterval = 1000000.0

        let microseconds = decimalValue * million

        self.init(tv_sec: Int(integerValue), tv_usec: POSIXMicroseconds(microseconds))
    }

    var TimeIntervalValue: TimeInterval {

        let secondsSince1970 = TimeInterval(self.tv_sec)

        let million: TimeInterval = 1000000.0

        let microseconds = TimeInterval(self.tv_usec) / million

        return secondsSince1970 + microseconds
    }
}

public extension timespec {

    init(timeInterval: TimeInterval) {

        let (integerValue, decimalValue) = modf(timeInterval)

        let billion: TimeInterval = 1000000000.0

        let nanoseconds = decimalValue * billion

        self.init(tv_sec: Int(integerValue), tv_nsec: Int(nanoseconds))
    }

    var TimeIntervalValue: TimeInterval {

        let secondsSince1970 = TimeInterval(self.tv_sec)

        let billion: TimeInterval = 1000000000.0

        let nanoseconds = TimeInterval(self.tv_nsec) / billion

        return secondsSince1970 + nanoseconds
    }
}

public extension tm {

    init(UTCSecondsSince1970: time_t) {
        var seconds = UTCSecondsSince1970
        let timePointer = gmtime(&seconds)!
        self = timePointer.pointee
    }
}

public extension POSIXError {

    /// Creates error from C ```errno```.
    static var fromErrorNumber: POSIXError? { return self.init(rawValue: errno) }
}

#if os(Linux)

    /// Enumeration describing POSIX error codes.
    public enum POSIXError: ErrorProtocol, RawRepresentable {
        case value(CInt)

        public init?(rawValue: CInt) {
            self = .value(rawValue)
        }

        public var rawValue: CInt {
            switch self {
            case let .value(rawValue): return rawValue
            }
        }
    }

#endif



// MARK: - Cross-Platform Support

#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)

    public typealias POSIXMicroseconds = __darwin_suseconds_t

#elseif os(Linux)

    public typealias POSIXMicroseconds = __suseconds_t

    public func modf(value: Double) -> (Double, Double) {

        var integerValue: Double = 0

        let decimalValue = modf(value, &integerValue)

        return (decimalValue, integerValue)
    }

#endif
