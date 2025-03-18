//
//  MovieServices.swift
//  MovieApps
//
//  Created by Faza Azizi on 17/03/25.
//

import Foundation
import Moya
import RxSwift

protocol MovieServiceProtocol {
    func getTrendingMovies(page: Int) -> Observable<MovieResponse>
    func getMovieDetail(id: Int) -> Observable<MovieDetail>
}

class MovieService: MovieServiceProtocol {
    private let provider = MoyaProvider<MovieAPI>()
    
    func getTrendingMovies(page: Int) -> Observable<MovieResponse> {
        return provider.rx.request(.trending(page: page))
            .filterSuccessfulStatusCodes()
            .map(MovieResponse.self)
            .asObservable()
    }
    
    func getMovieDetail(id: Int) -> Observable<MovieDetail> {
        return provider.rx.request(.movieDetail(id: id))
            .filterSuccessfulStatusCodes()
            .map(MovieDetail.self)
            .asObservable()
    }
}
