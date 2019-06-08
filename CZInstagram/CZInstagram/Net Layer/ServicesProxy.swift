//
//  ServicesProxy.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 3/6/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import CZNetworking

class ServicesProxy: NSObject {
    static let sharedHttpMananger = {
        return CZHTTPManager()
    }()

    private var baseURL: String
    private var presetParams: [AnyHashable: Any]?
    private let httpManager: CZHTTPManager
    
    override init() {
        fatalError("Must call designated initializer `init(baseURL:)`")
    }

    init(baseURL: String,
         presetParams: [AnyHashable: Any]? = nil,
         httpManager: CZHTTPManager = ServicesProxy.sharedHttpMananger) {
        self.baseURL = baseURL
        self.presetParams = presetParams
        self.httpManager = httpManager
        super.init()
    }
    
    /// Generic fetch method for Codable, returns model/models based on infer type
    func fetchModel<Model: Codable>(_ endPoint: String,
                                    params: [AnyHashable: Any]? = nil,
                                    dataKey: String? = "data",
                                    success: @escaping (Model) -> Void,
                                    failure: @escaping (Error) -> Void,
                                    cached: ((Model) -> Void)? = nil) {
        httpManager.GETCodableModel(
            urlString(endPoint),
            params: wrappedParams(params),
            dataKey: dataKey,
            success: success,
            failure: {(task, error) in
                failure(error)
            },
            cached: cached)
    }

    func postData(_ endPoint: String,
                  params: [AnyHashable: Any]? = nil,
                  success: @escaping HTTPRequestWorker.Success,
                  failure: @escaping HTTPRequestWorker.Failure,
                  cached: HTTPRequestWorker.Cached? = nil,
                  progress: HTTPRequestWorker.Progress? = nil) {
        httpManager.POST(urlString(endPoint),
                         params: wrappedParams(params),
                         success: { (dataTask, data) in
                            success(dataTask, data)
        }, failure: { (dataTask, error) in
            dbgPrint("Failed to post \(endPoint) Error: \n\n\(error)")
            failure(dataTask, error)
            fatalError()
        }, progress: progress)
    }

    func deleteData(_ endPoint: String,
                    params: [AnyHashable: Any]? = nil,
                    success: @escaping HTTPRequestWorker.Success,
                    failure: @escaping HTTPRequestWorker.Failure) {
        httpManager.DELETE(urlString(endPoint),
                           params: wrappedParams(params),
                           success: { (dataTask, data) in
                            success(dataTask, data)
        }, failure: { (dataTask, error) in
            dbgPrint("Failed to DELETE \(endPoint) Error: \n\n\(error)")
            failure(dataTask, error)
            fatalError()
        })
    }
}

private extension ServicesProxy {
    func urlString(_ endPoint: String) -> String {
        return baseURL + endPoint
    }

    func wrappedParams(_ params: [AnyHashable: Any]? = nil) ->  [AnyHashable: Any]? {
        var wrappedParams: [AnyHashable: Any] = params ?? [:]
        if let presetParams = presetParams {
            for (key, value) in presetParams {
                wrappedParams[key] = value
            }
        }
        return wrappedParams
    }
}
