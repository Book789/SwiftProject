//
//  HttpNetworkError.swift
//  SwiftProject
//
//  Created by cloud on 2024/3/13.
//

import Alamofire

enum HttpNetworkError: Error, CustomStringConvertible {
    // 网络层错误
    case noDataReceived
    case invalidResponseData
    case jsonParsingFailed(Error)
    case emptyResponse
    case invalidURL
    case networkUnavailable
    case requestTimeout
    case serverError(statusCode: Int)
    case decodingError(Error)
    case underlying(Error)
    
    // 业务层错误
    case unauthorized
    case forbidden
    case resourceNotFound
    case maintenanceMode
    case rateLimitExceeded
    case custom(message: String, code: Int)
    
    var description: String {
        switch self {
        case .noDataReceived:
            return "服务器未返回有效数据"
        case .invalidResponseData:
            return "响应数据格式无效"
        case .jsonParsingFailed(let error):
            return "JSON解析失败: \(error.localizedDescription)"
        case .emptyResponse:
            return "服务器返回空响应"
        case .invalidURL:
            return "无效的URL地址"
        case .networkUnavailable:
            return "请检查网络连接情况"
        case .requestTimeout:
            return "请求超时"
        case .serverError(let code):
            return "服务器错误(状态码: \(code))"
        case .decodingError(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .underlying(let error):
            return "网络请求错误: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden: 
            return "Access forbidden"
        case .resourceNotFound: 
            return "Resource not found"
        case .maintenanceMode: 
            return "Server maintenance"
        case .rateLimitExceeded: 
            return "Too many requests"
        case .custom(let message, _):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "请检查网络连接情况"
        case .requestTimeout:
            return "请求超时"
        case .unauthorized: 
            return "Please login again"
        case .rateLimitExceeded:
            return "Wait before retrying"
        default: return nil
        }
    }
    
    var statusCode: Int? {
        switch self {
        case .serverError(let code): return code
        case .unauthorized: return 401
        case .forbidden: return 403
        case .resourceNotFound: return 404
        case .rateLimitExceeded: return 429
        case .maintenanceMode: return 503
        case .custom(_, let code): return code
        default: return nil
        }
    }
}

extension AFError {
    func toNetworkError() -> HttpNetworkError {
        switch self {
        case .invalidURL: return .invalidURL
        case .sessionTaskFailed(let error as URLError) where error.code == .notConnectedToInternet:
            return .noInternetConnection
        case .sessionTaskFailed(let error as URLError) where error.code == .timedOut:
            return .requestTimeout
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                switch code {
                case 401: return .unauthorized
                case 403: return .forbidden
                case 404: return .resourceNotFound
                case 429: return .rateLimitExceeded
                case 503: return .maintenanceMode
                case 500...599: return .serverError(statusCode: code)
                default: return .underlying(self)
                }
            default: return .invalidResponseData
            }
        case .responseSerializationFailed(let reason):
            if case .decodingFailed(let error) = reason {
                return .decodingError(error)
            }
            return .invalidResponseData
        default:
            return .underlying(self)
        }
    }
}

struct NetworkErrorHandler {
    static func handle(_ error: Error) -> HttpNetworkError {
        if let afError = error.asAFError {
            return afError.toNetworkError()
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .dataNotAllowed:
                return .noInternetConnection
            case .timedOut:
                return .requestTimeout
            default:
                return .underlying(error)
            }
        } else {
            return .underlying(error)
        }
    }
    
    static func logError(_ error: HttpNetworkError) {
        print("[Network Error] \(error.description)")
        if let suggestion = error.recoverySuggestion {
            print("Suggestion: \(suggestion)")
        }
        if let code = error.statusCode {
            print("Status Code: \(code)")
        }
    }
}
