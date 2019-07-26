//
//  FeedListState.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

class FeedDetailsState: NSObject, CopyableState {
    typealias ViewModel = FeedDetailsViewModel
    var viewModel: FeedDetailsViewModel
    var viewState: FeedDetailsViewState = .initial

    required init(viewModel: FeedDetailsViewModel) {
        self.viewModel = viewModel
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

extension FeedDetailsState {
    func reduce(action: Action) {
        viewModel.reduce(action: action)
        viewState.reduce(action: action)
    }
}
