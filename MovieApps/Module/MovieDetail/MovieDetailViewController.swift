//
//  MovieDetailViewController.swift
//  MovieApps
//
//  Created by Faza Azizi on 18/03/25.
//

import UIKit
import RxSwift
import Kingfisher

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var starringLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var imdbButton: UIButton!
    @IBOutlet weak var containerButtonView: UIView!
    
    private let viewModel = MovieDetailViewModel()
    private let disposeBag = DisposeBag()
    var movieId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        if let id = movieId {
            viewModel.fetchMovieDetail(id: id)
        }
    }
    
    private func setupUI() {
        imdbButton.layer.cornerRadius = 8
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        
        containerButtonView.layer.cornerRadius = 8
        containerButtonView.layer.borderWidth = 1
        containerButtonView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupBindings() {
        viewModel.movieDetail
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movie in
                self?.updateUI(with: movie)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with movie: MovieDetail) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        
        if let director = movie.credits?.crew.first(where: { $0.job == "Director" }) {
            directorLabel.text = "\(director.name)"
        }
        
        let stars = movie.credits?.cast.prefix(3).map { $0.name }.joined(separator: ", ") ?? ""
        starringLabel.text = "\(stars)"
        
        let genres = movie.genres.map { $0.name }.joined(separator: ", ")
        genreLabel.text = "\(genres)"
        
        if let posterPath = movie.posterPath,
           let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            posterImageView.kf.setImage(with: url)
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        if let formattedRating = formatter.string(from: NSNumber(value: movie.voteAverage)) {
            ratingLabel.text = "\(formattedRating)"
        }
        
        imdbButton.isEnabled = movie.imdbId != nil
    }
    
    @IBAction func openIMDbTapped(_ sender: Any) {
        if let imdbId = viewModel.movieDetail.value.imdbId {
            let detailVC = MovieDetailWebViewViewController.create()
            detailVC.urlString = "https://www.imdb.com/title/\(imdbId)"
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    
    static func create() -> MovieDetailViewController {
        let viewController = MovieDetailViewController(nibName: "MovieDetailViewController", bundle: nil)
        return viewController
    }
}

