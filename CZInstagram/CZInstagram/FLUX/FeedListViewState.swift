//
//  FeedListViewState.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

/// ViewState for FeedList
enum FeedListViewState {
    case initial
    case loadingFeeds(FetchingFeedsType)
    case content
    case error
}

extension FeedListViewState: RootViewStatable {

}

extension FeedListViewState: State {
    mutating func reduce(action: Action) {
        switch action {
        case let FeedListAction.fetchingFeeds(fetchingType):
            self = .loadingFeeds(fetchingType)
        case FeedListAction.fetchedFeeds:
            self = .content
        default:
            break
        }
    }
}
