//
//  FeedListActionHandler.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

/// Middleware: Receives all actions and currentState of `Store`
class FeedListActionHandler: Middleware {
    typealias StateType = FeedListState
    var coordinator: FeedListViewController?
    var store: Store<FeedListState>?

    init(coordinator: FeedListViewController? = nil) {
        self.coordinator = coordinator
    }

    func process(action: Action, state: StateType) {
        CZUtils.dbgPrint("Received action: \(action)")
        switch action {
        case let CZFeedListViewAction.selectedCell(feedModel):
            // Present Details ViewController
            selectedCell(feedModel: feedModel)
            break
        case let FeedListAction.requestFetchingFeeds(type):
            guard let viewModel = store?.state.viewModel else { return }
            store?.fire(command: FetchFeedsCommand(type: type, viewModel: viewModel))
        case let CZFeedListViewAction.pullToRefresh(isFirst):
            guard let viewModel = store?.state.viewModel else { return }
            store?.fire(command: FetchFeedsCommand(type: .pullToRefresh(isFirst: isFirst), viewModel: viewModel))
        case CZFeedListViewAction.loadMore:
            guard let viewModel = store?.state.viewModel else { return }
            store?.fire(command: FetchFeedsCommand(type: .loadMore, viewModel: viewModel))
        default:
            break
        }
    }
}

private extension FeedListActionHandler {
    func selectedCell(feedModel: CZFeedModel) {
        if let viewModel = feedModel.viewModel as? FeedCellViewModel {
            let detailsVC = FeedDetailsViewController(feed: viewModel.feed)
            coordinator?.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
