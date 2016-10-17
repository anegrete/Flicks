//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by anegrete on 10/15/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    
    @IBOutlet weak var voteImageView: UIImageView!
    var movie:NSDictionary!

    //MARK: - View Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailView.frame.origin.y + detailView.frame.size.height)

        self.initMovieImageView()
        self.initTitle()
        self.initOverview()
        self.initReleaseDate()
        self.initVotesInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Initializations

    func initMovieImageView() {

        if let posterPath = movie["poster_path"] as? String {
            let baseUrlLowRes = "http://image.tmdb.org/t/p/w92"
            let imageLowResUrl = URL(string: baseUrlLowRes + posterPath)!

            let baseUrlHighRes = "http://image.tmdb.org/t/p/original"
            let imageHighResUrl = URL(string: baseUrlHighRes + posterPath)!

            let imageLowResRequest = URLRequest(url: imageLowResUrl)
            let imageHighResRequest = URLRequest(url: imageHighResUrl)

            self.movieImageView.setImageWith(
                imageLowResRequest,
                placeholderImage: nil,
                success: { (imageLowResRequest, imageLowResResponse, imageLowRes) -> Void in
                    
                    self.movieImageView.alpha = 0.0
                    self.movieImageView.image = imageLowRes;
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        self.movieImageView.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            self.movieImageView.setImageWith(
                                imageHighResRequest,
                                placeholderImage: imageLowRes,
                                success: { (imageHighResRequest, imageHighResponse, imageHighRes) -> Void in

                                    self.movieImageView.image = imageHighRes;
                                },
                                failure: { (request, response, error) -> Void in
                                    // TODO: Implement error handling
                                    print("Request failed")
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    print("Request failed")
            })
        }
    }

    func initTitle() {
        let title = movie["title"] as? String
        titleLabel.text = title
        self.navigationItem.title = title
    }

    func initOverview() {
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
    }
    
    func initReleaseDate() {
        let releaseDateStr = movie["release_date"] as? String
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let releaseDate = formatter.date(from: releaseDateStr!)

        formatter.dateFormat = "EEEE, MMM d, yyyy"
        releaseDateLabel.text = formatter.string(from: releaseDate!)
    }
    
    func initVotesInfo() {
        let voteAverage = movie["vote_average"] as! Double
        let voteCount = movie["vote_count"] as! Int
        voteAverageLabel.text = String(describing: voteAverage)
        voteCountLabel.text = String(describing: voteCount)
        voteImageView.image = voteImageView.image?.withRenderingMode(.alwaysTemplate)
        voteImageView.tintColor = UIColor.white
    }
}
