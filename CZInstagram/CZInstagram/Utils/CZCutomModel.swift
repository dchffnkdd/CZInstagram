//
//  CZCustomModel.swift
//  CZFacebook
//
//  Created by Cheng Zhang on 1/3/17.
//  Copyright © 2017 Groupon Inc. All rights reserved.
//

import UIKit
import EasyMapping
import CZUtils
import CZJsonModel
import ReactiveListViewKit

class CZCustomModel: NSObject, CZMappingProtocol, NSCopying, CZDictionaryable {
    fileprivate var serializedObject: CZDictionary?

    override init() { super.init() }
    required init(dictionary: CZDictionary) {
        super.init()
        let mapping = type(of: self).objectMapping()
        CZMapper.fillObject(self, fromExternalRepresentation: dictionary, with: mapping)
    }

    init(dictionary: CZDictionary, mapping: CZObjectMapping) {
        super.init()
        CZMapper.fillObject(self, fromExternalRepresentation: dictionary, with: mapping)
    }

    // MARK: - CZMappingProtocol
    class func objectMapping() -> CZObjectMapping {
        return CZObjectMapping(objectClass: self)
    }

    func update(with dictionary: CZDictionary, mapping: CZObjectMapping? = nil) -> CZCustomModel? {
        let mapping = mapping ?? type(of: self).objectMapping()
        CZMapper.fillObject(self, fromExternalRepresentation: dictionary, with: mapping)
        return self
    }

    var dictionaryVersion: CZDictionary {
        return CZSerializer.serializeObject(self, with: type(of: self).objectMapping())
    }

    func dictionaryVersion(mapping: CZObjectMapping) -> CZDictionary {
        return CZSerializer.serializeObject(self, with: mapping)
    }

    func isEqual(to model: Any) -> Bool {
        guard let model = model as? CZCustomModel,
            NSStringFromClass(type(of: model)) == NSStringFromClass(type(of: self)) else {
            return false
        }
        return (dictionaryVersion as NSDictionary).isEqual(to: model.dictionaryVersion)
    }
}

// MARK: - NSCopying
extension CZCustomModel {
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(dictionary: dictionaryVersion)
    }
}

extension CZCustomModel {
    override var description: String {
        return dictionaryVersion.description
    }
}

// MARK: - CZListDiffable
extension CZCustomModel: CZListDiffable {
    func isEqual(toDiffableObj object: AnyObject) -> Bool {
        return isEqual(to: object)
    }
}


