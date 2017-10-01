//
//  FeedDetailsViewState.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 9/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
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
    mutating func react(to event: Event) {
        switch event {
        case let FeedDetailsEvent.fetchingFeeds(fetchingType):
            self = .loadingFeeds(fetchingType)
        case FeedDetailsEvent.fetchedFeeds:
            self = .content
        default:
            break
        }
    }
}
