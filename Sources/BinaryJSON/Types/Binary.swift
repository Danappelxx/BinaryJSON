//
//  Binary.swift
//  BSON
//
//  Created by Dan Appel on 06/27/16.
//  Copyright © 2016 Dan Appel. All rights reserved.
//

import C7

public struct Binary {

    public enum Subtype {
        case generic
        case function
        case old
        case uuidOld
        case uuid
        case md5
        case user

        var cValue: bson_subtype_t {
            switch self {
            case .generic: return BSON_SUBTYPE_BINARY
            case .function: return BSON_SUBTYPE_FUNCTION
            case .old: return BSON_SUBTYPE_BINARY_DEPRECATED
            case .uuidOld: return BSON_SUBTYPE_UUID_DEPRECATED
            case .uuid: return BSON_SUBTYPE_UUID
            case .md5: return BSON_SUBTYPE_MD5
            case .user: return BSON_SUBTYPE_USER
            }
        }

        init(cValue: bson_subtype_t) {
            switch cValue {
            case BSON_SUBTYPE_BINARY: self = .generic
            case BSON_SUBTYPE_FUNCTION: self = .function
            case BSON_SUBTYPE_BINARY_DEPRECATED: self = .old
            case BSON_SUBTYPE_UUID_DEPRECATED: self = .uuidOld
            case BSON_SUBTYPE_UUID: self = .uuid
            case BSON_SUBTYPE_MD5: self = .md5
            case BSON_SUBTYPE_USER: self = .user
            default: self = .user
            }
        }
    }

    public var data: C7.Data
    public var subtype: Subtype

    public init(data: C7.Data, subtype: Subtype = .generic) {
        self.data = data
        self.subtype = subtype
    }
}

extension Binary: Equatable {}

public func ==(lhs: Binary, rhs: Binary) -> Bool {
    return lhs.data == rhs.data && lhs.subtype == rhs.subtype
}
