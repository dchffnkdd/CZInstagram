//
//  FeedListViewModel.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/4/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

class FeedListViewModel: NSObject, NSCopying {
    fileprivate(set) lazy var feeds: [Feed] = []
    fileprivate(set) lazy var storyUsers: [User] = {
        return CZMocker.shared.hotUsers
    }()
    fileprivate(set) lazy var suggestedUsers: [User] = {
        return CZMocker.shared.hotUsers
    }()
    
    fileprivate(set) var page: Int = 0
    fileprivate(set) var isLoadingFeeds: Bool = false
    fileprivate(set) var lastMinFeedId: String = "-1"
    var core: Core<FeedListState>?
    var sectionModelsResolver: CZFeedListFacadeView.SectionModelsResolver!

    override init() {
        super.init()
        
        /// SectionModelsResolver closure -  mapping feeds to sectionModels
        sectionModelsResolver = { (feeds: [Any]) -> [CZSectionModel] in
            guard let feeds = feeds as? [Feed] else { fatalError() }
            var sectionModels = [CZSectionModel]()
            
            // 1. HotUsers section
            let HotUsersFeedModels = self.storyUsers.flatMap { CZFeedModel(viewClass: HotUserCellView.self,
                                                                           viewModel: HotUserCellViewModel($0)) }
            
            let hotUsersSectionModel = CZSectionModel(isHorizontal: true,
                                                      heightForHorizontal: HotUserSection.heightForHorizontal,
                                                      feedModels: HotUsersFeedModels,
                                                      headerModel: CZFeedListSupplementaryTextFeedModel(title: "Stories",
                                                                                                        inset: UIEdgeInsets(top: 8,
                                                                                                                            left: 10,
                                                                                                                            bottom: 1,
                                                                                                                            right: 10)),
                                                      footerModel: CZFeedListSupplementaryLineFeedModel(),
                                                      sectionInset: UIEdgeInsets(top: 0,
                                                                                 left: 3,
                                                                                 bottom: 0,
                                                                                 right: 5))
            sectionModels.append(hotUsersSectionModel)
            
            // 2. Feeds section
            var feedModels = feeds.flatMap { CZFeedModel(viewClass: FeedCellView.self,
                                                         viewModel: FeedCellViewModel($0)) }
            
            // 3. SuggestedUsers - CellViewController
            if feedModels.count > 0 {
                let filteredSuggestedUsers = self.suggestedUsers
                let suggestedUsersFeedModel = CZFeedModel(viewClass: HotUsersCellViewController.self,
                                                          viewModel: HotUsersCellViewModel(filteredSuggestedUsers))
                feedModels.insert(suggestedUsersFeedModel, at: 3)
            }
            let feedsSectionModel = CZSectionModel(feedModels: feedModels)
            
            sectionModels.append(feedsSectionModel)
            return sectionModels
        }
    }
    
    func fetchFeeds(type fetchType: FetchingFeedsType = .fresh) {
        guard !isLoadingFeeds else {
            CZUtils.dbgPrint("Still in loading feeds process.")
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

        core?.fire(event: FeedListEvent.fetchingFeeds(fetchType))

        var params: [AnyHashable: Any] = ["count": "\(Instagram.FeedList.countPerPage)"]
        if isLoadMore {
            params["max_id"] = lastMinFeedId
        }
        Services.shared.fetchRecentMedia(params: params,
                                         success: {[weak self] feeds in
            guard let `self` = self else {
                return
            }
            self.isLoadingFeeds = false
            self.lastMinFeedId = feeds.last?.feedId ?? self.lastMinFeedId
 
            if fetchType == FetchingFeedsType.loadMore {
                self.feeds.append(contentsOf: feeds)
            } else {
                self.feeds = feeds
            }
            // Fire event after fetch feeds, notify subscribers to update UI
            self.core?.fire(event: FeedListEvent.fetchedFeeds)
        }, failure: { error in
                self.isLoadingFeeds = false
        }, cached: {[weak self] feeds in
            if case let .pullToRefresh(isFirst) = fetchType,
                isFirst {
                self?.feeds = feeds
                self?.core?.fire(event: FeedListEvent.gotCachedFeeds)
            }
        })
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

extension FeedListViewModel: State {
    func react(to event: Event) {
        feeds.forEach {$0.react(to: event)}

        switch event {
        case let CZFeedListViewEvent.selectedCell(feedModel):
            CZUtils.dbgPrint(feedModel)
            if let viewModel = feedModel.viewModel as? FeedCellViewModel {
                let success = { (data: Any?) in
                    self.fetchFeeds()
                }
                let failure = { (error: Error) in }
                if viewModel.feed.userHasLiked {
                    // Services.shared.unlikeFeed(feedId: viewModel.feed.feedId, success: success, failure: failure)
                } else {
                    // Services.shared.likeFeed(feedId: viewModel.feed.feedId, success: success, failure: failure)
                }
            }
        default:
            break
        }
    }
}

