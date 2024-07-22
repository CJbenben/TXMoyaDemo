//
//  NetworkManager.swift
//  TXMoyaDemo
//
//  Created by powershare on 2024/7/1.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import Alamofire
import Moya
import RxSwift

/// 超时时长
private var requestTimeOut: Double = 30
/// 网络请求成功回调
typealias RequestSuccessCallback<APIResponseModel: Codable> = ((APIResponseModel) -> Void)
/// 网络请求失败回调
typealias RequestFailureCallback = ((_ error: Error?) -> Void)
/// 网络请求使用 delegate 回调
protocol MoyaProviderDelegate: AnyObject {
    func callApiDidSuccess<T: Codable>(target: TargetType, response: APIResponseModel<T>)
    func callApiDidFailure(target: TargetType, error: Error?)
}

private let endpointClosure = { (target: TargetType) -> Endpoint in
    /// 这里把endpoint重新构造一遍主要为了解决网络请求地址里面含有? 时无法解析的bug https://github.com/Moya/Moya/issues/1198
    let url = target.baseURL.absoluteString + target.path
    var task = target.task
    var appId = Api.environment.appId
    let timeStamp: Int = Int(Date().timeIntervalSince1970 * 1000)
    var publicParams: [String: Any] = [:]
    publicParams["appId"] = appId
    publicParams["timestamp"] = timeStamp
    publicParams["key"] = "8880f93f279f023e0f0820bf48c74875"
    
    switch target.task {
    case .requestPlain:
        publicParams["data"] = [:]
        publicParams["sign"] = "sign"
        task = .requestParameters(parameters: publicParams, encoding: URLEncoding.default)
    case .requestParameters(var parameters, let encoding):
        publicParams["data"] = parameters
        publicParams["sign"] = "sign"
        task = .requestParameters(parameters: publicParams, encoding: encoding)
    default:
        break
    }

    var endpoint = Endpoint(
        url: url,
        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
        method: target.method,
        task: task,
        httpHeaderFields: target.headers
    )
    
    // 自定义 User-Agent
    let customUserAgent = "YourCustomUserAgent/1.0.0"
//    HTTPHeader.defaultUserAgent
    endpoint = endpoint.adding(newHTTPHeaderFields: ["User-Agent2": customUserAgent])
    
    
    requestTimeOut = 30
    // 针对于某个具体的业务模块来做接口配置
    if let apiTarget = target as? MultiTarget,
       let target = apiTarget.target as? Api {
        switch target {
        case .testApiNoParams:
            requestTimeOut = 50
            return endpoint
        default:
            return endpoint
        }
    }
    return endpoint
}

private let requestClosure = { (endpoint: Endpoint, closure: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        request.timeoutInterval = requestTimeOut
        closure(.success(request))
    } catch {
        closure(.failure(MoyaError.underlying(error, nil)))
    }
}

/// 网络请求插件
private let networkPlugin = NetworkActivityPlugin.init(networkActivityClosure: { change, target in
    print("networkPlugin -> change \(change), target = \(target)")
    switch change {
    case .began:
        print("请求网络开始 - 显示 loading")
    case .ended:
        print("请求网络结束 - 隐藏 loading")
    }
})

private let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
private let loggerPlugin = NetworkLoggerPlugin(configuration: loggerConfig)

/// 网络请求发送的核心初始化方法，创建网络请求对象
#if DEBUG
fileprivate let provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, requestClosure: requestClosure, plugins: [networkPlugin, loggerPlugin], trackInflights: true)
#else
fileprivate let provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, requestClosure: requestClosure, plugins: [networkPlugin, loggerPlugin], trackInflights: true)
#endif

private let sampleDataProvider = MoyaProvider<MultiTarget>(stubClosure: { _ in
    return .immediate
})

@discardableResult
func NetWorkRequest<T: Codable>(_ target: TargetType, modelType: T.Type, delegate: MoyaProviderDelegate) -> Cancellable? {
    return NetWorkRequest(target, modelType: modelType, delegate: delegate, successCallback: nil, failureCallback: nil)
}

@discardableResult
func NetWorkRequest<T: Codable>(_ target: TargetType, modelType: T.Type, successCallback:@escaping RequestSuccessCallback<APIResponseModel<T>>, failureCallback: RequestFailureCallback? = nil) -> Cancellable? {
    return NetWorkRequest(target, modelType: modelType, delegate: nil, successCallback: successCallback, failureCallback: failureCallback)
}

func NetWorkRxRequest<T: Codable>(_ target: TargetType, modelType: T.Type, useSampleData: Bool = false, successCallback:@escaping RequestSuccessCallback<APIResponseModel<T>>, failureCallback: RequestFailureCallback? = nil) {
    if !UIDevice.isNetworkConnect {
        print("网络出现了问题")
        return
    }
    
    var providerRequest = provider
    if useSampleData {
        providerRequest = sampleDataProvider
    }
    let _ = providerRequest.rx.request(MultiTarget(target)).map(APIResponseModel<T>.self)
        .subscribe (
        onSuccess: { response in
            successCallback(response)
        },
        onFailure: { error in
            failureCallback?(error)
        },
        onDisposed: {
            print("onDisposed")
        }
    )
}

@discardableResult
func NetWorkRequest<T: Codable>(_ target: TargetType, modelsType: [T].Type, delegate: MoyaProviderDelegate) -> Cancellable? {
    return NetWorkRequest(target, modelsType: modelsType, delegate: delegate, successCallback: nil, failureCallback: nil)
}

@discardableResult
func NetWorkRequest<T: Codable>(_ target: TargetType, modelsType: [T].Type, successCallback:@escaping RequestSuccessCallback<APIResponseModel<[T]>>, failureCallback: RequestFailureCallback? = nil) -> Cancellable? {
    return NetWorkRequest(target, modelsType: modelsType, delegate: nil, successCallback: successCallback, failureCallback: failureCallback)
}

func NetWorkRxRequest<T: Codable>(_ target: TargetType, modelsType: [T].Type, successCallback:@escaping RequestSuccessCallback<APIResponseModel<[T]>>, failureCallback: RequestFailureCallback? = nil) {
    if !UIDevice.isNetworkConnect {
        print("网络出现了问题")
        return
    }
    let _ = provider.rx.request(MultiTarget(target)).map(APIResponseModel<[T]>.self).subscribe (
        onSuccess: { response in
            successCallback(response)
        },
        onFailure: { error in
            failureCallback?(error)
        },
        onDisposed: {
            print("onDisposed")
        }
    )
}

// MARK Private Method
private func NetWorkRequest<T: Codable>(_ target: TargetType, modelType: T.Type, delegate: MoyaProviderDelegate? = nil, successCallback: RequestSuccessCallback<APIResponseModel<T>>? = nil, failureCallback: RequestFailureCallback? = nil) -> Cancellable? {
    if !UIDevice.isNetworkConnect {
        print("网络出现了问题")
        return nil
    }
    return provider.request(MultiTarget(target)) { result in
        switch result {
        case let .success(response):
            do {
                let response = try JSONDecoder().decode(APIResponseModel<T>.self, from: response.data)
                if response.error_code == 0 {
                    
                } else {
                    
                }
                if let delegate = delegate {
                    delegate.callApiDidSuccess(target: target, response: response)
                } else if let successCallback = successCallback {
                    successCallback(response)
                }
            } catch {
                print("response.data 转 \(modelType) 失败： \(error.localizedDescription)")
            }
        case .failure(let error):
            if let delegate = delegate {
                delegate.callApiDidFailure(target: target, error: error)
            } else if let failureCallback = failureCallback {
                failureCallback(error)
            }
        }
    }
}

func NetWorkRequest<T: Codable>(_ target: TargetType, modelsType: [T].Type, delegate: MoyaProviderDelegate? = nil, successCallback: RequestSuccessCallback<APIResponseModel<[T]>>? = nil, failureCallback: RequestFailureCallback? = nil) -> Cancellable? {
    if !UIDevice.isNetworkConnect {
        print("网络出现了问题")
        return nil
    }
    return provider.request(MultiTarget(target)) { result in
        switch result {
        case let .success(response):
            do {
                let response = try JSONDecoder().decode(APIResponseModel<[T]>.self, from: response.data)
                if response.error_code == 0 {
                    
                } else {
                    
                }
                if let delegate = delegate {
                    delegate.callApiDidSuccess(target: target, response: response)
                } else if let successCallback = successCallback {
                    successCallback(response)
                }
            } catch {
                print("response.data 转 \(modelsType) 失败： \(error.localizedDescription)")
            }
        case let .failure(error as NSError):
            if let delegate = delegate {
                delegate.callApiDidFailure(target: target, error: error)
            } else if let failureCallback = failureCallback {
                failureCallback(error)
            }
        }
    }
}

extension UIDevice {
    static var isNetworkConnect: Bool {
        let network = NetworkReachabilityManager()
        return network?.isReachable ?? true // 无返回就默认网络已连接
    }
}
