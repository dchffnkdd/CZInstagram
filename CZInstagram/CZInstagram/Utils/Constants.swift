//
//  Constants.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/2/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

struct Constants {
    static let incrementalUpdateOn = false
}

enum Instagram {
    static let baseURLString = "https://api.instagram.com"
    static let clientID = "6d6cef1256f04a06b1a50b5140bb83cd"
    static let redirectURI = "http://CZInstagram.com"
    static let clientSecret = "7ddab91705424a78a8c456908e721920"
    static let scope = "public_content+follower_list+comments+relationships+likes"
    static let authUrl = "https://api.instagram.com/oauth/authorize/"

    enum FeedList {
        static let countPerPage = 25
    }

    enum FeedDetails {
        static let countPerPage = 5
    }
}
