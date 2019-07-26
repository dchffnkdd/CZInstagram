//
//  FeedListState.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

protocol RootViewStatable {}


class FeedListState: NSObject, CopyableState {
    typealias ViewModel = FeedListViewModel
    var viewModel: FeedListViewModel
    var viewState: FeedListViewState = .initial

    required init(viewModel: FeedListViewModel) {
        self.viewModel = viewModel
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

extension FeedListState {
    func reduce(action: Action) {
        viewModel.reduce(action: action)
        viewState.reduce(action: action)
    }
}
