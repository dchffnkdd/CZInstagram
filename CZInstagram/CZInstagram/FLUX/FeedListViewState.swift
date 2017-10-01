//
//  FeedListViewState.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
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
    mutating func react(to event: Event) {
        switch event {
        case let FeedListEvent.fetchingFeeds(fetchingType):
            self = .loadingFeeds(fetchingType)
        case FeedListEvent.fetchedFeeds:
            self = .content
        default:
            break
        }
    }
}
