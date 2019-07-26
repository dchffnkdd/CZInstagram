//
//  FeedDetailsViewState.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

/// ViewState for FeedList
enum FeedDetailsViewState {
    case initial
    case loadingFeeds(FetchingFeedsType)
    case content
    case error
}

extension FeedDetailsViewState: RootViewStatable {

}

extension FeedDetailsViewState: State {
    mutating func reduce(action: Action) {
        switch action {
        case let FeedDetailsAction.fetchingFeeds(fetchingType):
            self = .loadingFeeds(fetchingType)
        case FeedDetailsAction.fetchedFeeds:
            self = .content
        default:
            break
        }
    }
}
