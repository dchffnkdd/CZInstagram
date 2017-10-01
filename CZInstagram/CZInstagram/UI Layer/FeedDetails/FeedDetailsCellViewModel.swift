//
//  CommentCellViewModel.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/4/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import ReactiveListViewKit
import ReactiveListViewKit

class FeedDetailsCellViewModel: NSObject, CZFeedViewModelable {
    var diffId: String {
        return currentClassName + comment.commentId
    }
    fileprivate(set) var comment: Comment
    var userName: String? {return comment.user?.userName}
    var content: String? {return comment.content}
    var portraitUrl: URL? {
        guard let urlStr = comment.user?.portraitUrl else {return nil}
        return URL(string: urlStr)
    }

    required init(_ comment: Comment) {
        self.comment = comment
        super.init()
    }

    func isEqual(toDiffableObj object: AnyObject) -> Bool {
        guard let object = object as? FeedDetailsCellViewModel else {return false}
        return comment.isEqual(toDiffableObj: object.comment)
    }

    func copy(with zone: NSZone?) -> Any {
        let commentCopy = comment.copy() as! Comment
        return FeedDetailsCellViewModel(commentCopy)
    }
}

extension FeedDetailsCellViewModel: State {
    func react(to event: Event) {

    }
}
