//
//  MovieDetailViewModel.swift
//  MovieApps
//
//  Created by Faza Azizi on 18/03/25.
//

import Foundation
import RxSwift
import RxCocoa

class MovieDetailViewModel {
    let movieDetail = BehaviorRelay<MovieDetail>(value: MovieDetail.empty)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<Error>()
    
    private let movieService: MovieServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
    }
    
    func fetchMovieDetail(id: Int) {
        isLoading.accept(true)
        
        movieService.getMovieDetail(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movie in
                self?.movieDetail.accept(movie)
                self?.isLoading.accept(false)
            }, onError: { [weak self] error in
                self?.error.accept(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
