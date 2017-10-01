//
//  FeedDetailsViewController.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/2/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import ReactiveListViewKit

class FeedDetailsViewController: UIViewController {
    fileprivate(set) var core: Core<FeedDetailsState>
    fileprivate(set) var viewModel: FeedDetailsViewModel
    fileprivate var eventHandler: FeedDetailsEventHandler
    fileprivate(set) var feedListFacadeView: CZFeedListFacadeView?
    fileprivate var isFirstVisible = false

    init(feed: Feed) {
        self.viewModel = FeedDetailsViewModel(feed: feed)
        self.eventHandler = FeedDetailsEventHandler()
        core = Core<FeedDetailsState>.init(state: FeedDetailsState(viewModel: viewModel), middlewares: [self.eventHandler])
        self.viewModel.core = core
        self.eventHandler.core = core
        super.init(nibName:nil, bundle: .main)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("Should call designated initilizer.") }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !isFirstVisible {
            isFirstVisible = true
            core.add(subscriber: self)
            setupFeedDetailsView()
            core.fire(event: CZFeedListViewEvent.pullToRefresh(isFirst: true))
        }
    }
}

fileprivate extension FeedDetailsViewController {
    func setupFeedDetailsView() {
        feedListFacadeView = CZFeedListFacadeView(sectionModelsResolver: viewModel.sectionModelsResolver,
                                                  onEvent: { [weak self] event in
            self?.core.fire(event: event)
        }, backgroundColor: ReactiveListViewKit.GreyBGColor,
           minimumLineSpacing: 0,
           allowLoadMore: false)
        feedListFacadeView?.overlayOnSuperViewController(self)
    }
}

extension FeedDetailsViewController: Subscriber {
    func update(with state: FeedDetailsState, prevState: FeedDetailsState?) {
        var isLoading = false
        if case let FeedDetailsViewState.loadingFeeds(loadingType) = state.viewState,
            case .pullToRefresh = loadingType  {
            isLoading = true
        }
        feedListFacadeView?.isLoading = isLoading
        reloadFeedDetailsView()
    }
    func reloadFeedDetailsView() {
        feedListFacadeView?.batchUpdate(withFeeds: core.state.viewModel.feeds)
    }
}


