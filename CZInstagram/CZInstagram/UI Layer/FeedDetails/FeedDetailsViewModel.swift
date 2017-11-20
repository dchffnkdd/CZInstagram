//
//  FeedDetailsViewModel.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/4/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

class FeedDetailsViewModel: NSObject, NSCopying {
    fileprivate(set) var feed: Feed
    fileprivate(set) var feeds: [Comment] = []
    fileprivate(set) var page: Int = 0
    fileprivate(set) var isLoadingFeeds: Bool = false
    fileprivate(set) var lastMinFeedId: String = "-1"
    var core: Core<FeedDetailsState>?

    init(feed: Feed) {
        self.feed = feed
        super.init()
    }

    lazy var sectionModelsResolver: CZFeedListFacadeView.SectionModelsResolver = { (feeds: [Any]) -> [CZSectionModel] in
        guard let feeds = feeds as? [Comment] else { fatalError() }
        // Header Section
        let headCellViewModel = FeedCellViewModel(self.feed)
        headCellViewModel.isInFeedDetails = true
        let headerFeedModel = CZFeedModel(viewClass: FeedCellView.self,
                                          viewModel: headCellViewModel)
        let headerSectionModel = CZSectionModel(feedModels: [headerFeedModel])

        // Feeds Section
        let feedModels = feeds.flatMap { CZFeedModel(viewClass: FeedDetailsCellView.self,
                                                     viewModel: FeedDetailsCellViewModel($0)) }
        let feedsSectionModel = CZSectionModel(feedModels: feedModels)
        return [headerSectionModel, feedsSectionModel]
    }

    func fetchFeeds(type fetchType: FetchingFeedsType = .fresh) {
        guard !isLoadingFeeds else {
            print("Still in loading feeds process.")
            return
        }
        isLoadingFeeds = true
        var isLoadMore = false
        switch fetchType {
        case .fresh:
            page = 0
            lastMinFeedId = "-1"
        case .loadMore:
            isLoadMore = true
        default:
            break
        }

        core?.fire(event: FeedDetailsEvent.fetchingFeeds(fetchType))

        var params: [AnyHashable: Any] = ["count": "\(Instagram.FeedDetails.countPerPage)"]
        if isLoadMore {
            params["max_id"] = lastMinFeedId
        }
        Services.shared.fetchComments(feedId: feed.feedId,
                                      params: params,
                                         success: {[weak self] feeds in
                                            guard let `self` = self else {
                                                return
                                            }
                                            self.isLoadingFeeds = false
                                            self.lastMinFeedId = feeds.last?.commentId ?? self.lastMinFeedId

                                            if fetchType == FetchingFeedsType.loadMore {
                                                self.feeds.append(contentsOf: feeds)
                                            } else {
                                                self.feeds = feeds
                                            }
                                            // Fire event after fetchedFeeds, notify VC to update UI
                                            self.core?.fire(event: FeedDetailsEvent.fetchedFeeds)
            }, failure: { error in
                self.isLoadingFeeds = false
        })
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

extension FeedDetailsViewModel: State {
    func react(to event: Event) {
        feeds.forEach {$0.react(to: event)}

        switch event {
        case let CZFeedListViewEvent.selectedCell(feedModel):
            print(feedModel)
            if let viewModel = feedModel.viewModel as? FeedCellViewModel {
                let success = { (data: Any?) in
                    self.fetchFeeds()
                }
                let failure = { (error: Error) in }
                if viewModel.feed.userHasLiked {
                    Services.shared.unlikeFeed(feedId: viewModel.feed.feedId, success: success, failure: failure)
                } else {
                    Services.shared.likeFeed(feedId: viewModel.feed.feedId, success: success, failure: failure)
                }
            }
        default:
            break
        }
    }
}
