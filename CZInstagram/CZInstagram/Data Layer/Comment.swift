//
//  Comment
//  CZInstagram
//
//  Created by Cheng Zhang on 1/3/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

/// Model of Comment
class Comment: ReactiveListDiffable {
    let commentId: String
    let user: User?
    let content: String?
    let createTime: String?
    
    // MARK: - CZListDiffable
    func isEqual(toDiffableObj object: AnyObject) -> Bool {
        return isEqual(toCodable: object)
    }
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        return codableCopy(with: zone)
    }
}

extension Comment: State {
    func reduce(action: Action) {
    }

}
