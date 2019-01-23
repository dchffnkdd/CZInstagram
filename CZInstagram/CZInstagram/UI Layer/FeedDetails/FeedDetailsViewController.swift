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
    private(set) var core: Core<FeedDetailsState>
    private(set) var viewModel: FeedDetailsViewModel
    private(set) var eventHandler: FeedDetailsEventHandler
    private(set) var feedListFacadeView: CZFeedListFacadeView?
    private(set) var isFirstVisible = false

    init(feed: Feed) {
        viewModel = FeedDetailsViewModel(feed: feed)
        eventHandler = FeedDetailsEventHandler()
        core = Core<FeedDetailsState>.init(state: FeedDetailsState(viewModel: viewModel), middlewares: [eventHandler])
        viewModel.core = core
        eventHandler.core = core
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

private extension FeedDetailsViewController {
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


