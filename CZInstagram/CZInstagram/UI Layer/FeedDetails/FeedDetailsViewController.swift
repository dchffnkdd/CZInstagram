//
//  FeedDetailsViewController.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/2/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

class FeedDetailsViewController: UIViewController {
    private(set) var store: Store<FeedDetailsState>
    private(set) var viewModel: FeedDetailsViewModel
    private(set) var actionHandler: FeedDetailsActionHandler
    private(set) var feedListFacadeView: CZFeedListFacadeView?
    private(set) var isFirstVisible = false

    init(feed: Feed) {
        viewModel = FeedDetailsViewModel(feed: feed)
        actionHandler = FeedDetailsActionHandler()
        store = Store<FeedDetailsState>.init(state: FeedDetailsState(viewModel: viewModel), middlewares: [actionHandler])
        viewModel.store = store
        actionHandler.store = store
        super.init(nibName:nil, bundle: .main)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("Should call designated initilizer.") }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !isFirstVisible {
            isFirstVisible = true
            store.subscribe(self)
            setupFeedDetailsView()
            store.dispatch(action: CZFeedListViewAction.pullToRefresh(isFirst: true))
        }
    }
}

private extension FeedDetailsViewController {
    func setupFeedDetailsView() {
        feedListFacadeView = CZFeedListFacadeView(sectionModelsTransformer: viewModel.sectionModelsTransformer,
                                                  onAction: { [weak self] action in
            self?.store.dispatch(action: action)
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
        feedListFacadeView?.batchUpdate(withFeeds: store.state.viewModel.feeds)
    }
}


