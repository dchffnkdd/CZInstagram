//
//  FeedListActionHandler.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

/// Middleware: Receives all actions and current state of store
class FeedDetailsActionHandler: Middleware {
    typealias StateType = FeedDetailsState
    var store: Store<FeedDetailsState>?

    func process(action: Action, state: StateType) {
        CZUtils.dbgPrint("Received action: \(action)")
        switch action {
        case let FeedListAction.requestFetchingFeeds(type):
            guard let viewModel = (store?.state.viewModel) else { return }
            store?.fire(command: FetchCommentsCommand(type: type, viewModel: viewModel))
        case let CZFeedListViewAction.pullToRefresh(isFirst):
            guard let viewModel = (store?.state.viewModel) else { return }
            store?.fire(command: FetchCommentsCommand(type: .pullToRefresh(isFirst: isFirst), viewModel: viewModel))
        case CZFeedListViewAction.loadMore:
            guard let viewModel = (store?.state.viewModel) else { return }
            store?.fire(command: FetchCommentsCommand(type: .loadMore, viewModel: viewModel))
        default:
            break
        }
    }
}
