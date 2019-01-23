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
    private var presetParams: [AnyHashable: Any]? // ["access_token": ""] etc.
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
        typealias Completion = (Model) -> Void
        let modelingHandler = { (completion: Completion?, task: URLSessionDataTask?, data: Data?) in
            let data: Data? = {
                guard let dataKey = dataKey,
                      let dict = CZHTTPJsonSerializer.deserializedObject(with: data) as? CZDictionary,
                      let dataDict = dict[dataKey] else {
                        return data
                }
                return CZHTTPJsonSerializer.jsonData(with: dataDict)
            }()
            let model: Model = CodableHelper.decode(data)!
            completion?(model)
        }
        
        getData(endPoint,
                params: params,
                success: { (task, data) in
            modelingHandler(success, task, data)
        },failure: {(task, error) in
            failure(error)
        }, cached: { (task, data) in
            modelingHandler(cached, task, data)
        })
    }
    
    private func getData(_ endPoint: String,
                         params: [AnyHashable: Any]? = nil,
                         success: @escaping HTTPRequestWorker.Success,
                         failure: @escaping HTTPRequestWorker.Failure,
                         cached: HTTPRequestWorker.Cached? = nil,
                         progress: HTTPRequestWorker.Progress? = nil) {
        httpManager.GET(urlString(endPoint),
                        params: wrappedParams(params),
                        success: { (sessionTask, data) in
                            success(sessionTask, data)
        }, failure: { (sessionTask, error) in
            dbgPrint("Failed to fetch \(endPoint) Error: \n\n\(error)")
            failure(sessionTask, error)
        }, cached: cached,
           progress: progress)
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
