//
//  NetworkService.swift
//  MovieApps
//
//  Created by Faza Azizi on 17/03/25.
//

import Foundation
import Moya
import RxSwift

enum MovieAPI {
    case trending(page: Int)
    case movieDetail(id: Int)
}

extension MovieAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }
    
    var path: String {
        switch self {
        case .trending:
            return "/trending/movie/day"
        case .movieDetail(let id):
            return "/movie/\(id)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .trending(let page):
            return .requestParameters(
                parameters: ["api_key": Constants.apiKey, "page": page],
                encoding: URLEncoding.queryString
            )
        case .movieDetail:
            return .requestParameters(
                parameters: ["api_key": Constants.apiKey, "append_to_response": "credits"],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

