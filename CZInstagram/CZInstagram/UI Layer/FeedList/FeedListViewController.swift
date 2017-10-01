//
//  FeedListViewController.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/2/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import ReactiveListViewKit

class FeedListViewController: UIViewController {
    fileprivate(set) var core: Core<FeedListState>
    fileprivate(set) var viewModel: FeedListViewModel
    fileprivate var eventHandler: FeedListEventHandler
    fileprivate(set) var feedListFacadeView: CZFeedListFacadeView?
    fileprivate(set) var isFirstVisible: Bool = false

    init() { 
        self.viewModel = FeedListViewModel()
        self.eventHandler = FeedListEventHandler()
        self.core = Core<FeedListState>.init(state: FeedListState(viewModel: viewModel), middlewares: [self.eventHandler])
        super.init(nibName:nil, bundle: .main)
        viewModel.core = core
        eventHandler.core = core
        eventHandler.coordinator = self
    }
    required init?(coder aDecoder: NSCoder) { fatalError("Should call designated initilizer.") }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstVisible {
            isFirstVisible = true
            // There's topGap in put in `viewDidLoad` (no topLayoutGuide? - worked before)
            core.add(subscriber: self)
            setupFeedListView()
            core.fire(event: CZFeedListViewEvent.pullToRefresh(isFirst: true))
        }
    }
}

fileprivate extension FeedListViewController {
    func setupFeedListView() {
        feedListFacadeView = CZFeedListFacadeView(sectionModelsResolver: viewModel.sectionModelsResolver,
                                                  onEvent: {[weak self] event in
            self?.core.fire(event: event)
        })
        feedListFacadeView?.overlayOnSuperViewController(self)
    }
}

extension FeedListViewController: Subscriber {
    func update(with state: FeedListState, prevState: FeedListState?) {
        var isLoading = false
        if case let FeedListViewState.loadingFeeds(loadingType) = state.viewState,
           case .pullToRefresh = loadingType  {
            isLoading = true
        }
        feedListFacadeView?.isLoading = isLoading
        reloadFeedListView()
    }
    func reloadFeedListView() {
        feedListFacadeView?.batchUpdate(withFeeds: core.state.viewModel.feeds)
    }
}


