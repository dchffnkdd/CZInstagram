//
//  FeedListViewController.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/2/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

class FeedListViewController: UIViewController {
    fileprivate(set) var core: Core<FeedListState>
    fileprivate var feedListFacadeView: CZReactiveFeedListFacadeView<FeedListState>?

    init() {
        // Setup `Core` of FLUX pattern
        let viewModel = FeedListViewModel()
        let eventHandler = FeedListEventHandler()
        self.core = Core<FeedListState>.init(state: FeedListState(viewModel: viewModel), middlewares: [eventHandler])
        
        super.init(nibName:nil, bundle: .main)
        viewModel.core = core
        eventHandler.core = core
        eventHandler.coordinator = self
    }
    required init?(coder aDecoder: NSCoder) { fatalError("Should call designated initilizer.") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFeedListView()
        core.add(subscriber: self)
        
        core.fire(event: CZFeedListViewEvent.pullToRefresh(isFirst: true))
    }
}

fileprivate extension FeedListViewController {
    func setupFeedListView() {
        feedListFacadeView = CZReactiveFeedListFacadeView<FeedListState>(core: core,
                                                                         sectionModelsResolver: core.state.viewModel.sectionModelsResolver,
                                                                         parentViewController:self)
        feedListFacadeView?.overlayOnSuperViewController(self, insets: Constants.feedListViewInsets)
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


