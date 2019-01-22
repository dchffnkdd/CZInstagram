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

    fileprivate var baseURL: String
    fileprivate var presetParams: [AnyHashable: Any]? // ["access_token": ""] etc.
    fileprivate let dataKey: String?
    fileprivate let httpManager: CZHTTPManager
    
    override init() {
        fatalError("Must call designated initializer `init(baseURL:)`")
    }

    init(baseURL: String,
         presetParams: [AnyHashable: Any]? = nil,
         dataKey: String? = "data",
         httpManager: CZHTTPManager = ServicesProxy.sharedHttpMananger) {
        self.baseURL = baseURL
        self.presetParams = presetParams
        self.dataKey = dataKey
        self.httpManager = httpManager
        super.init()
    }

    func fetchOneModel<Model: CZDictionaryable>(_ endPoint: String,
                       params: [AnyHashable: Any]? = nil,
                       dataKey: String? = nil,
                       success: @escaping (Model) -> Void,
                       failure: @escaping (Error) -> Void,
                       cached: ((Model) -> Void)? = nil) {
        typealias ModelingHandler = (Model) -> Void
        let modelingHandler = {(outerHandler: ModelingHandler?, task: URLSessionDataTask?, data: Any?) in
            
            var retrivedData: CZDictionary?
            if let dataKey = dataKey ?? self.dataKey {
                retrivedData = (data as? CZDictionary)?[dataKey] as? CZDictionary
            } else {
                retrivedData = data as? CZDictionary
            }
            
            guard let retrivedDataNonNil = retrivedData else {
                failure(CZNetError.returnType)
                return
            }
            let res = Model(dictionary: retrivedDataNonNil)
            outerHandler?(res)
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

    func fetchManyModels<Model: CZDictionaryable>(_ endPoint: String,
                         params: [AnyHashable: Any]? = nil,
                         dataKey: String? = nil,
                         success: @escaping ([Model]) -> Void,
                         failure: @escaping (Error) -> Void,
                         cached: (([Model]) -> Void)? = nil) {
        typealias ModelingHandler = ([Model]) -> Void
        let modelingHandler = {(outerHandler: ModelingHandler?, task: URLSessionDataTask?, data: Any?) in
            
            var retrivedData: [CZDictionary]?
            if let dataKey = dataKey ?? self.dataKey {
                retrivedData = (data as? CZDictionary)?[dataKey] as? [CZDictionary]
            } else {
                retrivedData = data as? [CZDictionary]
            }
            
            guard let retrivedDataNonNil = retrivedData else {
                failure(CZNetError.returnType)
                return
            }
            
            let res = retrivedDataNonNil.flatMap {Model(dictionary: $0)}
            outerHandler?(res)
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
    
    func getData(_ endPoint: String,
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
            CZUtils.dbgPrint("Failed to fetch \(endPoint) Error: \n\n\(error)")
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
            CZUtils.dbgPrint("Failed to post \(endPoint) Error: \n\n\(error)")
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
            CZUtils.dbgPrint("Failed to DELETE \(endPoint) Error: \n\n\(error)")
            failure(dataTask, error)
            fatalError()
        })
    }
}

fileprivate extension ServicesProxy {
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
