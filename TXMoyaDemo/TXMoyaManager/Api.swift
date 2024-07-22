//
//  Api.swift
//  TXMoyaDemo
//
//  Created by powershare on 2024/7/1.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import Foundation
import Moya

enum ApiEnvironmentType {
    case dev
    case uat
    case prd
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .dev
        case 1:
            self = .uat
        case 2:
            self = .prd
        default:
            self = .prd
        }
    }
}

protocol Environment {
    var baseURL: URL { get }
    var appId: String { get }
}

struct EnvironmentDev: Environment {
    var baseURL: URL { return URL(string: "http://v.juhe.cn/")! }
    var appId: String { return "appId-dev" }
}

struct EnvironmentUat: Environment {
    var baseURL: URL { return URL(string: "http://v.juhe.cn/")! }
    var appId: String { return "appId-uat" }
}

struct EnvironmentPrd: Environment {
    var baseURL: URL { return URL(string: "http://v.juhe21.cn/")! }
    var appId: String { return "appId-prd" }
}

enum Api {
    case testApiNoParams
    case testApiHasParams(params: [String: Any]?)
    case testApiSampleData
    case testApiRetry(params: [String: Any]?)
}

extension Api: TargetType {
    static var environment: Environment {
        switch getApiEnvironment() {
        case .dev:
            return EnvironmentDev()
        case .uat:
            return EnvironmentUat()
        case .prd:
            return EnvironmentPrd()
        }
    }
    
    var baseURL: URL {
        return Api.environment.baseURL
    }
    
    var path: String {
        switch self {
        case .testApiNoParams:
            return "toutiao/index"
        case .testApiHasParams:
            return "toutiao/index2"
        case .testApiSampleData:
            return "toutiao/sampleData"
        case .testApiRetry:
            return "weather/index"
        }
    }
    
    var task: Moya.Task {
        var requestParams: [String: Any] = [:]
        switch self {
        case .testApiNoParams:
            return .requestPlain
        case .testApiHasParams(params: let params):
            if let params = params {
                requestParams = params
            }
        case .testApiSampleData:
            return .requestPlain
        case .testApiRetry(params: let params):
            if let params = params {
                requestParams = params
            }
            return .requestParameters(parameters: requestParams, encoding: URLEncoding.default)
        }
        return .requestParameters(parameters: requestParams, encoding: JSONEncoding.default)
    }
    
    var method: Moya.Method {
        switch self {
        case .testApiNoParams:
            return .post
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .testApiSampleData:
            break
        default:
            break
        }
        return """
                {
                    "reason": "sample-data",
                    "result": {
                        "index": "1",
                        "data": [{
                            "id": "1589f954e57bba15b40d795e0c2dd700",
                            "title": "金乡农商银行“零钱包”架起“连心桥”",
                            "time": "2024-07-19 10:37:00",
                            "price": 18.88,
                            "count": 123
                        }],
                        "currPage": "1",
                        "pageSize": "30"
                    },
                    "error_code": 0
                }
                """.data(using: .utf8)!
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = [:]
        headers["Content-type"] = "application/x-www-form-urlencoded"
        headers["Authorization"] = "token" + "token"
        return headers
    }
}

private func getApiEnvironment() -> ApiEnvironmentType {
    if let api_environment_str = Bundle.main.infoDictionary?["API_ENVIRONMENT"] as? String,
        let api_environment_int = Int(api_environment_str) {
        return ApiEnvironmentType(rawValue: api_environment_int) ?? .prd
    }
    return .prd
}
