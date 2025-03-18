//
//  MovieAppsTests.swift
//  MovieAppsTests
//
//  Created by Faza Azizi on 17/03/25.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import MovieApps

final class MovieAppsTests: XCTestCase {
    var viewModel: MovieListViewModel!
    var mockMovieService: MockMovieService!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockMovieService = MockMovieService()
        viewModel = MovieListViewModel(movieService: mockMovieService)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
        mockMovieService = nil
        scheduler = nil
        disposeBag = nil
        super.tearDown()
    }

    func testLoadMoviesSuccess() {
        let mockMovies = [
            Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/path1.jpg", releaseDate: "2023-01-01", voteAverage: 7.5),
            Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/path2.jpg", releaseDate: "2023-02-01", voteAverage: 8.0)
        ]
        let mockResponse = MovieResponse(page: 1, results: mockMovies, totalPages: 1, totalResults: 2)
        mockMovieService.mockTrendingMoviesResponse = mockResponse
        
        viewModel.loadInitialMovies()
        
        let movies = try! viewModel.allMovies.toBlocking(timeout: 1.0).first()
        XCTAssertEqual(movies?.count, 2)
        XCTAssertEqual(movies?[0].id, 1)
        XCTAssertEqual(movies?[0].title, "Test Movie 1")
        XCTAssertEqual(movies?[1].id, 2)
        XCTAssertEqual(movies?[1].title, "Test Movie 2")
    }
    
    func testSearchFunctionality() {
        let mockMovies = [
            Movie(id: 1, title: "Avengers", overview: "Overview 1", posterPath: "/path1.jpg", releaseDate: "2023-01-01", voteAverage: 7.5),
            Movie(id: 2, title: "Batman", overview: "Overview 2", posterPath: "/path2.jpg", releaseDate: "2023-02-01", voteAverage: 8.0)
        ]
        let mockResponse = MovieResponse(page: 1, results: mockMovies, totalPages: 1, totalResults: 2)
        mockMovieService.mockTrendingMoviesResponse = mockResponse
        
        viewModel.loadInitialMovies()
        
        let filteredMoviesObserver = scheduler.createObserver([Movie].self)
        
        viewModel.filteredMovies
            .bind(to: filteredMoviesObserver)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([.next(10, "Avengers")])
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let filteredMovies = try! viewModel.filteredMovies.toBlocking(timeout: 1.0).first()
        XCTAssertEqual(filteredMovies?.count, 1)
        XCTAssertEqual(filteredMovies?[0].title, "Avengers")
        
        viewModel.searchText.accept("Superman")
        
        let hasResults = try! viewModel.hasSearchResults.toBlocking(timeout: 1.0).first()
        XCTAssertFalse(hasResults ?? true)
    }

}

class MockMovieService: MovieServiceProtocol {
    var mockTrendingMoviesResponse: MovieResponse?
    var mockMovieDetailResponse: MovieDetail?
    var mockError: Error?
    
    func getTrendingMovies(page: Int) -> Observable<MovieResponse> {
        if let error = mockError {
            return Observable.error(error)
        }
        
        if let response = mockTrendingMoviesResponse {
            return Observable.just(response)
        }
        
        return Observable.error(NSError(domain: "Test", code: 404, userInfo: nil))
    }
    
    func getMovieDetail(id: Int) -> Observable<MovieDetail> {
        if let error = mockError {
            return Observable.error(error)
        }
        
        if let response = mockMovieDetailResponse {
            return Observable.just(response)
        }
        
        return Observable.error(NSError(domain: "Test", code: 404, userInfo: nil))
    }
}

