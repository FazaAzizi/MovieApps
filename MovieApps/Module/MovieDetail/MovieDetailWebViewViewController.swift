//
//  MovieDetailWebViewViewController.swift
//  MovieApps
//
//  Created by Faza Azizi on 20/03/25.
//

import UIKit
import WebKit

class MovieDetailWebViewViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadWebPage()
    }
    
    private func loadWebPage() {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    
    static func create() -> MovieDetailWebViewViewController {
        let viewController = MovieDetailWebViewViewController(nibName: "MovieDetailWebViewViewController", bundle: nil)
        return viewController
    }
}
