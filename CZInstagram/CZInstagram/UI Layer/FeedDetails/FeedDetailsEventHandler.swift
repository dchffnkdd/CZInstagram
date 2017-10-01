//
//  FeedListEventHandler.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import ReactiveListViewKit

/// Middleware: Receives all events and current state of core
class FeedDetailsEventHandler: Middleware {
    typealias StateType = FeedDetailsState
    var core: Core<FeedDetailsState>?

    func process(event: Event, state: StateType) {
        print("Received event: \(event)")
        switch event {
        case let FeedListEvent.requestFetchingFeeds(type):
            guard let viewModel = (core?.state.viewModel) else { return }
            core?.fire(command: FetchCommentsCommand(type: type, viewModel: viewModel))
        case let CZFeedListViewEvent.pullToRefresh(isFirst):
            guard let viewModel = (core?.state.viewModel) else { return }
            core?.fire(command: FetchCommentsCommand(type: .pullToRefresh(isFirst: isFirst), viewModel: viewModel))
        case CZFeedListViewEvent.loadMore:
            guard let viewModel = (core?.state.viewModel) else { return }
            core?.fire(command: FetchCommentsCommand(type: .loadMore, viewModel: viewModel))
        default:
            break
        }
    }
}
