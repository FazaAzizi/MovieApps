//
//  SearchBarView.swift
//  MovieApps
//
//  Created by Faza Azizi on 17/03/25.
//

import UIKit
import RxSwift
import RxCocoa

class SearchBarView: UIView {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var closeImageView: UIImageView!
    
    private let disposeBag = DisposeBag()
    private let _searchText = BehaviorRelay<String>(value: "")
    
    var searchText: Observable<String> {
        return _searchText.asObservable()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFromNib()
    }
    
    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func setupFromNib() {
        guard let view = self.loadViewFromNib(nibName: "SearchBarView") else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view)
        
        setupUI()
        setupBindings()
    }

    
    private func setupUI() {
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        searchTextField.placeholder = "Search movies..."
        closeImageView.isHidden = true
        
        closeImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        closeImageView.addGestureRecognizer(tapGesture)
        
        closeImageView.image = UIImage(systemName: "xmark.circle.fill")
        closeImageView.tintColor = .gray
        closeImageView.contentMode = .scaleAspectFit
        
        searchImageView.tintColor = .gray
        searchImageView.contentMode = .scaleAspectFit
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.searchTextField.text = ""
                self?._searchText.accept("")
                self?.searchTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        searchTextField.rx.text.orEmpty
            .bind(to: _searchText)
            .disposed(by: disposeBag)

        searchTextField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: closeImageView.rx.isVisible)
            .disposed(by: disposeBag)
    }
    
    func setPlaceholder(_ text: String) {
        searchTextField.placeholder = text
    }
}

extension Reactive where Base: UIView {
    var isVisible: Binder<Bool> {
        return Binder(self.base) { view, visible in
            view.isHidden = !visible
        }
    }
}
