//
//  FeedDetailsEvents.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/4/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

// MARK: - Events

enum FeedDetailsEvent: Event {
    case requestFetchingFeeds(FetchingFeedsType)
    case fetchingFeeds(FetchingFeedsType)
    case gotCachedFeeds
    case fetchedFeeds
}

class FetchCommentsCommand: Command {
    typealias StateType = FeedDetailsState
    let type: FetchingFeedsType
    let viewModel: FeedDetailsViewModel
    init(type: FetchingFeedsType,
         viewModel: FeedDetailsViewModel) {
        self.type = type
        self.viewModel = viewModel
    }
    public func execute(state: FeedDetailsState, core: Core<FeedDetailsState>) {
        viewModel.fetchFeeds(type: type)
    }
}




