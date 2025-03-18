//
//  MovieListTVC.swift
//  MovieApps
//
//  Created by Faza Azizi on 17/03/25.
//

import UIKit
import Kingfisher

class MovieListTVC: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let identifier = String(describing: MovieListTVC.self)
    
    static let nib = {
       UINib(nibName: identifier, bundle: nil)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension MovieListTVC {
    func configure(data: Movie) {
        titleLabel.text = data.title
        posterImageView.kf.setImage(with: data.posterURL)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        if let formattedRating = formatter.string(from: NSNumber(value: data.voteAverage)) {
            ratingLabel.text = "\(formattedRating) / 10"
        }
        dateLabel.text = data.releaseDate
    }
}
