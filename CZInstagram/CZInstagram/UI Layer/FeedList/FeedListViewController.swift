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
    /// Store that maintains State
    private(set) var store: Store<FeedListState>
    /// List view that populates feeds
    private(set) var feedListFacadeView: CZReactiveFeedListFacadeView<FeedListState>?

    init() {
        // Setup `Store` of FLUX pattern
        let viewModel = FeedListViewModel()
        let actionHandler = FeedListActionHandler()
        store = Store<FeedListState>.init(state: FeedListState(viewModel: viewModel), middlewares: [actionHandler])
        super.init(nibName:nil, bundle: .main)
        
        viewModel.store = store
        actionHandler.store = store
        actionHandler.coordinator = self
    }
    required init?(coder aDecoder: NSCoder) { fatalError("Should call designated initilizer.") }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up list view
        setupFeedListView()
        // Add self as subscriber of `store`, will get notified on state change
        store.subscribe(self)
        // Fire `pullToRefresh` action that triggers fetch feeds command
        store.dispatch(action: CZFeedListViewAction.pullToRefresh(isFirst: true))
    }
}

private extension FeedListViewController {
    func setupFeedListView() {
        feedListFacadeView = CZReactiveFeedListFacadeView<FeedListState>(store: store,
                                                                         sectionModelsTransformer: store.state.viewModel.sectionModelsTransformer,
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
        feedListFacadeView?.batchUpdate(withFeeds: store.state.viewModel.feeds)
    }
}


