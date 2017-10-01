//
//  User.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/3/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
import EasyMapping
import ReactiveListViewKit
import CZUtils
import CZJsonModel

@objc class CZUser: CZCustomModel {
    var userId: String?
    var userName: String?
    var fullName: String?

    override init() {
        super.init()
    }
    required init(dictionary: CZDictionary) {
        super.init(dictionary: dictionary)
    }

    override class func objectMapping() -> CZObjectMapping {
        let allMapping = super.objectMapping()
        let mapping = CZObjectMapping(objectClass: self)
        mapping.mapProperties(from: ["id": "userId",
                                     "username": "userName",
                                     "full_name": "fullName",
            ])
        allMapping.mapProperties(fromMappingObject: mapping)
        return allMapping
    }
}


