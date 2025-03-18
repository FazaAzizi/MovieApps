//
//  MovieListViewModel.swift
//  MovieApps
//
//  Created by Faza Azizi on 17/03/25.
//

import Foundation
import RxSwift
import RxCocoa
import Network

class MovieListViewModel {
    private let movieService: MovieServiceProtocol
    private let disposeBag = DisposeBag()
    private let networkManager = NetworkManager.shared
    
    let allMovies = BehaviorRelay<[Movie]>(value: [])
    let filteredMovies = BehaviorRelay<[Movie]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<Error>()
    let searchText = BehaviorRelay<String>(value: "")
    let hasData = BehaviorRelay<Bool>(value: true)
    let hasSearchResults = BehaviorRelay<Bool>(value: true)
    
    private var currentPage = 1
    private var totalPages = 1
    private let itemsFromEndThreshold = 5
    
    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
        setupBindings()
        
        networkManager.isConnected
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isConnected in
                if isConnected {
                    self?.loadInitialMovies()
                } else {
                    self?.loadMoviesFromCoreData()
                }
            })
            .disposed(by: disposeBag)
    }

    
    private func loadMoviesFromCoreData() {
        let savedMovies = CoreDataManager.shared.fetchMovies()
        self.allMovies.accept(savedMovies)
        self.hasData.accept(!savedMovies.isEmpty)
    }
    
    private func setupBindings() {
        Observable.combineLatest(allMovies, searchText)
            .map { movies, query in
                if query.isEmpty {
                    return movies
                } else {
                    let filtered = movies.filter { movie in
                        return movie.title.lowercased().contains(query.lowercased())
                    }
                    self.hasSearchResults.accept(!filtered.isEmpty)
                    return filtered
                }
            }
            .bind(to: filteredMovies)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    func loadInitialMovies() {
        currentPage = 1
        fetchMovies(page: currentPage)
    }
    
    func loadMoreMoviesIfNeeded(index: Int) {
        let currentCount = filteredMovies.value.count
        if shouldLoadMoreData(index: index, currentCount: currentCount) {
            currentPage += 1
            fetchMovies(page: currentPage)
        }
    }
    
    func fetchMovies(page: Int) {
        if isLoading.value { return }
        
        isLoading.accept(true)
        if networkManager.isConnected.value {
            movieService.getTrendingMovies(page: page)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
                    
                    self.totalPages = response.totalPages
                    
                    if page == 1 {
                        self.allMovies.accept(response.results)
                        CoreDataManager.shared.saveMovies(response.results)
                        self.hasData.accept(!response.results.isEmpty)
                    } else {
                        let currentMovies = self.allMovies.value
                        self.allMovies.accept(currentMovies + response.results)
                    }
                    
                    self.isLoading.accept(false)
                }, onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.error.accept(error)
                    
                    self?.loadMoviesFromCoreData()
                })
                .disposed(by: disposeBag)
        } else {
            loadMoviesFromCoreData()
            isLoading.accept(false)
        }
    }
    
    private func shouldLoadMoreData(index: Int, currentCount: Int) -> Bool {
        return index >= currentCount - itemsFromEndThreshold && currentPage < totalPages && !isLoading.value
    }
}

