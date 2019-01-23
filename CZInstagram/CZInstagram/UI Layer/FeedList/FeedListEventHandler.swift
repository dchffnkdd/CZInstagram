//
//  FeedListEventHandler.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

/// Middleware: Receives all events and currentState of `Core`
class FeedListEventHandler: Middleware {
    typealias StateType = FeedListState
    var coordinator: FeedListViewController?
    var core: Core<FeedListState>?

    init(coordinator: FeedListViewController? = nil) {
        self.coordinator = coordinator
    }

    func process(event: Event, state: StateType) {
        CZUtils.dbgPrint("Received event: \(event)")
        switch event {
        case let CZFeedListViewEvent.selectedCell(feedModel):
            // Present Details ViewController
            selectedCell(feedModel: feedModel)
            break
        case let FeedListEvent.requestFetchingFeeds(type):
            guard let viewModel = core?.state.viewModel else { return }
            core?.fire(command: FetchFeedsCommand(type: type, viewModel: viewModel))
        case let CZFeedListViewEvent.pullToRefresh(isFirst):
            guard let viewModel = core?.state.viewModel else { return }
            core?.fire(command: FetchFeedsCommand(type: .pullToRefresh(isFirst: isFirst), viewModel: viewModel))
        case CZFeedListViewEvent.loadMore:
            guard let viewModel = core?.state.viewModel else { return }
            core?.fire(command: FetchFeedsCommand(type: .loadMore, viewModel: viewModel))
        default:
            break
        }
    }
}

private extension FeedListEventHandler {
    func selectedCell(feedModel: CZFeedModel) {
        if let viewModel = feedModel.viewModel as? FeedCellViewModel {
            let detailsVC = FeedDetailsViewController(feed: viewModel.feed)
            coordinator?.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
