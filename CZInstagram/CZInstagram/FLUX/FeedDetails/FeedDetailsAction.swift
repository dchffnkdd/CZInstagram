//
//  FeedDetailsActions.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/4/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

// MARK: - Actions

enum FeedDetailsAction: Action {
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
    public func execute(state: FeedDetailsState, store: Store<FeedDetailsState>) {
        viewModel.fetchFeeds(type: type)
    }
}




