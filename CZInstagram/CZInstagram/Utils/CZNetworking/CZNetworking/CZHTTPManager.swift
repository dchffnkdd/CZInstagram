//
//  CZHTTPManager.swift
//  CZNetworking
//
//  Created by Cheng Zhang on 1/9/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit
/**
 Asynchronous HTTP requests manager based on NSOperationQueue
 */
open class CZHTTPManager: NSObject {
    public static let shared = CZHTTPManager()
    private let queue: OperationQueue
    private let httpCache: CZHTTPCache
    public enum Constant {
        public static let maxConcurrentOperationCount = 5
    }
    
    public init(maxConcurrentOperationCount: Int = Constant.maxConcurrentOperationCount) {
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = maxConcurrentOperationCount
        httpCache = CZHTTPCache()
        super.init()
    }
    
    public func GET(_ urlStr: String,
                    params: HTTPRequestWorker.Params? = nil,
                    headers: HTTPRequestWorker.Headers? = nil,
                    success: @escaping HTTPRequestWorker.Success,
                    failure: @escaping HTTPRequestWorker.Failure,
                    cached: HTTPRequestWorker.Cached? = nil,
                    progress: HTTPRequestWorker.Progress? = nil) {
        startRequester(
            .GET,
            urlStr: urlStr,
            params: params,
            headers: headers,
            success: success,
            failure: failure,
            cached: cached,
            progress: progress)
    }
    
    // MARK: - CZDictionaryable
    
    public func GetManyModels<Model: CZDictionaryable>(_ urlStr: String,
                                                       params: HTTPRequestWorker.Params? = nil,
                                                       headers: HTTPRequestWorker.Headers? = nil,
                                                       dataKey: String? = nil,
                                                       success: @escaping ([Model]) -> Void,
                                                       failure: HTTPRequestWorker.Failure? = nil,
                                                       cached: (([Model]) -> Void)? = nil,
                                                       progress: HTTPRequestWorker.Progress? = nil) {
        
        typealias ModelingHandler = ([Model]) -> Void
        let modelingHandler = {(outerHandler: ModelingHandler?, task: URLSessionDataTask?, data: Any?) in
            var retrivedData: [CZDictionary]?
            if let dataKey = dataKey {
                retrivedData = (data as? CZDictionary)?[dataKey] as? [CZDictionary]
            } else {
                retrivedData = data as? [CZDictionary]
            }
            
            guard let retrivedDataNonNil = retrivedData else {
                failure?(nil, CZNetError.returnType)
                return
            }
            let res = retrivedDataNonNil.compactMap {Model(dictionary: $0)}
            outerHandler?(res)
        }
        
        GET(urlStr,
            params: params,
            headers: headers,
            success: { (task, data) in
                modelingHandler(success, task, data)
            },
            failure: failure!,
            cached: { (task, data) in
                modelingHandler(cached, task, data)
            },
            progress: progress)
    }
    
    public func GetOneModel<Model: CZDictionaryable>(_ urlStr: String,
                                                     params: HTTPRequestWorker.Params? = nil,
                                                     headers: HTTPRequestWorker.Headers? = nil,
                                                     dataKey: String? = nil,
                                                     success: @escaping (Model) -> Void,
                                                     failure: HTTPRequestWorker.Failure? = nil,
                                                     cached: ((Model) -> Void)? = nil,
                                                     progress: HTTPRequestWorker.Progress? = nil) {
        
        typealias ModelingHandler = (Model) -> Void
        let modelingHandler = {(outerHandler: ModelingHandler?, task: URLSessionDataTask?, data: Any?) in
            var retrivedData: CZDictionary?
            if let dataKey = dataKey {
                retrivedData = (data as? CZDictionary)?[dataKey] as? CZDictionary
            } else {
                retrivedData = data as? CZDictionary
            }
            
            guard let retrivedDataNonNil = retrivedData else {
                failure?(nil, CZNetError.returnType)
                return
            }
            let res = Model(dictionary: retrivedDataNonNil)
            outerHandler?(res)
        }
        
        GET(urlStr,
            params: params,
            headers: headers,
            success: { (task, data) in
                modelingHandler(success, task, data)
        },
            failure: failure!,
            cached: { (task, data) in
                modelingHandler(cached, task, data)
        },
            progress: progress)
    }
    
    public func POST(_ urlStr: String,
                     contentType: HTTPRequestWorker.ContentType = .formUrlencoded,
                     params: HTTPRequestWorker.Params? = nil,
                     data: Data? = nil,
                     headers: HTTPRequestWorker.Headers? = nil,
                     success: @escaping HTTPRequestWorker.Success,
                     failure: @escaping HTTPRequestWorker.Failure,
                     progress: HTTPRequestWorker.Progress? = nil) {
        startRequester(
            .POST(contentType, data),
            urlStr: urlStr,
            params: params,
            headers: headers,
            success: success,
            failure: failure,
            progress: progress)
    }
    
    public func DELETE(_ urlStr: String,
                       params: HTTPRequestWorker.Params? = nil,
                       headers: HTTPRequestWorker.Headers? = nil,
                       success: @escaping HTTPRequestWorker.Success,
                       failure: @escaping HTTPRequestWorker.Failure) {
        startRequester(
            .DELETE,
            urlStr: urlStr,
            params: params,
            headers: headers,
            success: success,
            failure: failure)
    }
}

private extension CZHTTPManager {
    func startRequester(_ requestType: HTTPRequestWorker.RequestType,
                        urlStr: String,
                        params: HTTPRequestWorker.Params? = nil,
                        headers: HTTPRequestWorker.Headers? = nil,
                        success: @escaping HTTPRequestWorker.Success,
                        failure: @escaping HTTPRequestWorker.Failure,
                        cached: HTTPRequestWorker.Cached? = nil,
                        progress: HTTPRequestWorker.Progress? = nil) {
        let op = HTTPRequestWorker(
            requestType,
            url: URL(string: urlStr)!,
            params: params,
            headers: headers,
            httpCache: self.httpCache,
            success: success,
            failure: failure,
            cached: cached,
            progress: progress)
        queue.addOperation(op)
    }
}

public typealias CZDictionary = [AnyHashable : Any]

public protocol CZDictionaryable: NSObjectProtocol {
    init(dictionary: CZDictionary)
}
