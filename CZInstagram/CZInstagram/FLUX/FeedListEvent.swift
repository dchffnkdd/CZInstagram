//
//  FeedListEvents.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/4/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

// MARK: - Events

struct LikeFeedEvent: Event {
    var feed: Feed
}

enum FeedListEvent: Event {
    case requestFetchingFeeds(FetchingFeedsType)
    case fetchingFeeds(FetchingFeedsType)
    case gotCachedFeeds
    case fetchedFeeds
}

enum FetchingFeedsType: Equatable {
    case pullToRefresh(isFirst: Bool)
    case loadMore
    case fresh
    
    public static func ==(lhs: FetchingFeedsType, rhs: FetchingFeedsType) -> Bool {
        switch (lhs, rhs) {
        case let (.pullToRefresh(isFirstL), .pullToRefresh(isFirstR)):
            return isFirstL == isFirstR
        case (.loadMore, .loadMore):
            return true
        case (.fresh, .fresh):
            return true
        default:
            return false
        }
    }
}

// MARK: - Commands

class FetchFeedsCommand: Command {
    typealias StateType = FeedListState
    let type: FetchingFeedsType
    let viewModel: FeedListViewModel
    init(type: FetchingFeedsType,
         viewModel: FeedListViewModel) {
        self.type = type
        self.viewModel = viewModel
    }
    public func execute(state: FeedListState, core: Core<FeedListState>) {
        viewModel.fetchFeeds(type: type)
    }
}




