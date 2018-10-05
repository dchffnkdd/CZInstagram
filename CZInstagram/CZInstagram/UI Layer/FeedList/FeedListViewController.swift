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
    /// Core - composed of Dispatcher/Store
    fileprivate(set) var core: Core<FeedListState>
    /// List view that renders feeds
    fileprivate(set) var feedListFacadeView: CZReactiveFeedListFacadeView<FeedListState>?

    init() {
        // Setup `Core` of FLUX pattern
        let viewModel = FeedListViewModel()
        let eventHandler = FeedListEventHandler()
        core = Core<FeedListState>.init(state: FeedListState(viewModel: viewModel), middlewares: [eventHandler])
        super.init(nibName:nil, bundle: .main)
        
        viewModel.core = core
        eventHandler.core = core
        eventHandler.coordinator = self
    }
    required init?(coder aDecoder: NSCoder) { fatalError("Should call designated initilizer.") }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up list view
        setupFeedListView()
        // Add self as subscriber of `core`, will get notice on state change
        core.add(subscriber: self)
        // Fire `pullToRefresh` event that triggers fetch feeds command
        core.fire(event: CZFeedListViewEvent.pullToRefresh(isFirst: true))
    }
}

fileprivate extension FeedListViewController {
    func setupFeedListView() {
        feedListFacadeView = CZReactiveFeedListFacadeView<FeedListState>(core: core,
                                                                         sectionModelsResolver: core.state.viewModel.sectionModelsResolver,
                                                                         parentViewController: self)
        feedListFacadeView?.overlayOnSuperViewController(self, insets: Constants.feedListViewInsets)
    }
}

extension FeedListViewController: Subscriber {
    /// When state changes, UI layer updates accordingly with new state
    func update(with state: FeedListState, prevState: FeedListState?) {
        let isLoading: Bool = {
            guard case let FeedListViewState.loadingFeeds(loadingType) = state.viewState, case .pullToRefresh = loadingType else {
                return false
            }
            return true
        }()
        feedListFacadeView?.isLoading = isLoading
        reloadFeedListView()
    }
    
    func reloadFeedListView() {
        feedListFacadeView?.batchUpdate(withFeeds: core.state.viewModel.feeds)
    }
}


