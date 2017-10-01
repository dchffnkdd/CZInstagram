//
//  FeedListState.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/5/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
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
    func react(to event: Event) {
        viewModel.react(to: event)
        viewState.react(to: event)
    }
}

// Singlton Core for FeedListViewController
//class FeedListCore: NSObject {
//    static var shared: Core<FeedListState> {
//        guard let _core = FeedListCore._core else {
//            fatalError("Should initialize core first.")
//        }
//        return _core
//    }
//    fileprivate(set) static var _core: Core<FeedListState>?
//    static func initializeCore(with viewModel: FeedListViewModel, middlewares: [AnyMiddleware] = []) -> Core<FeedListState> {
//        let state = FeedListState(viewModel: viewModel)
//        let core = Core<FeedListState>(state: state, middlewares: middlewares)
//        FeedListCore._core = core
//        return core
//    }
//}
