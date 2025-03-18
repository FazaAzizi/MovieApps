//
//  MovieListViewController.swift
//  MovieApps
//
//  Created by Faza Azizi on 17/03/25.
//

import UIKit
import RxSwift
import RxCocoa

class MovieListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    private let viewModel = MovieListViewModel()
    private let refreshControl = UIRefreshControl()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadInitialMovies()
    }
    
    private func setupUI() {
        title = "Home"
        
        tableView.register(MovieListTVC.nib, forCellReuseIdentifier: MovieListTVC.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        searchBarView.searchText
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        viewModel.filteredMovies
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: MovieListTVC.identifier, cellType: MovieListTVC.self)) { (row, movie, cell) in
                cell.configure(data: movie)
                self.viewModel.loadMoreMoviesIfNeeded(index: row)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let selectedMovie = self.viewModel.filteredMovies.value[indexPath.row]
                self.navigateToDetail(with: selectedMovie.id)
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading && !(self?.refreshControl.isRefreshing ?? false) {
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        NetworkManager.shared.isConnected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isConnected in
                if !isConnected {
                    self?.showOfflineIndicator()
                } else {
                    self?.hideOfflineIndicator()
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            NetworkManager.shared.isConnected,
            viewModel.hasData
        )
        .subscribe(onNext: { [weak self] isConnected, hasData in
            if !isConnected && !hasData {
                self?.showEmptyState(message: "You're offline and don't have any saved movies. Connect to the internet to browse movies.")
                self?.searchBarView.searchTextField.isEnabled = false
            } else {
                self?.hideEmptyState()
            }
        })
        .disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.hasSearchResults,
            viewModel.searchText
        )
        .subscribe(onNext: { [weak self] hasResults, searchText in
            if !hasResults && !searchText.isEmpty {
                self?.showEmptyState(message: "No results found for '\(searchText)'")
            } else {
                self?.hideEmptyState()
            }
        })
        .disposed(by: disposeBag)

    }
    
    
    @objc private func refreshData() {
        viewModel.loadInitialMovies()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToDetail(with movieId: Int) {
        let detailVC = MovieDetailViewController.create()
        detailVC.movieId = movieId
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showOfflineIndicator() {
        let offlineView = UIView()
        offlineView.backgroundColor = .red
        offlineView.tag = 100
        
        let label = UILabel()
        label.text = "You're offline. Showing saved data."
        label.textColor = .white
        label.textAlignment = .center
        
        offlineView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: offlineView.topAnchor),
            label.leadingAnchor.constraint(equalTo: offlineView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: offlineView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: offlineView.bottomAnchor)
        ])
        
        view.addSubview(offlineView)
        offlineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            offlineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            offlineView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func hideOfflineIndicator() {
        if let offlineView = view.viewWithTag(100) {
            offlineView.removeFromSuperview()
        }
    }
    
    private func showEmptyState(message: String) {
        emptyLabel.text = message
        emptyLabel.isHidden = false
    }

    private func hideEmptyState() {
        emptyLabel.isHidden = true
    }
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}


extension MovieListViewController {
    static func create() -> MovieListViewController {
        let viewController = MovieListViewController(nibName: "MovieListViewController", bundle: nil)
        return viewController
    }
}
