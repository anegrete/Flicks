//
//  MoviesViewController.swift
//  Flicks
//
//  Created by anegrete on 10/15/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController {

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var networkView: UIView!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    @IBOutlet weak var viewTypeSegmentedControl: UISegmentedControl!

    var movies: [NSDictionary]?
    var endpoint: String!
    var hud:MBProgressHUD?

    // Search
    let searchController = UISearchController(searchResultsController: nil)
    var filteredMovies = [NSDictionary]()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.requestMovies()
        self.setupRefreshControl()
        self.setupSearchController()
        self.customizeNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isOnline(isOnline: AFNetworkReachabilityManager.shared().isReachable)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Requests

    func requestMovies() {

        self.showLoading()
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )

        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    
                    print("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.moviesTableView.reloadData()
                    self.moviesCollectionView.reloadData()
                    self.hideLoading()

                    // Uncomment for demo:
                    // self.perform(#selector(self.hideLoading), with: nil, afterDelay: 0.5)
                }
            }
        });
        task.resume()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! MovieDetailViewController

        var indexPath: IndexPath
        if sender is MovieCell {
            indexPath = moviesTableView.indexPath(for: (sender as! MovieCell))!
        }
        else {
            indexPath = moviesCollectionView.indexPath(for: (sender as! MovieCollectionViewCell))!
        }

        destinationViewController.movie = self.movieAt(indexPath: indexPath)
    }

    func customizeNavigationBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }

    // MARK: - Refresh Control

    func setupRefreshControl() {

        let refreshControlTableView = UIRefreshControl()
        refreshControlTableView.tintColor = UIColor.white
        refreshControlTableView.addTarget(self,
                                 action: #selector(refreshControlAction(refreshControl:)),
                                 for: UIControlEvents.valueChanged)
        moviesTableView.insertSubview(refreshControlTableView, at: 0)

        let refreshControlCollectionView = UIRefreshControl()
        refreshControlCollectionView.tintColor = UIColor.white
        refreshControlCollectionView.addTarget(self,
                                          action: #selector(refreshControlAction(refreshControl:)),
                                          for: UIControlEvents.valueChanged)
        moviesCollectionView.insertSubview(refreshControlCollectionView, at: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        if (searchController.isActive) {
            refreshControl.endRefreshing()
            return
        }

        self.showLoading()

        print("Going to refresh")
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {

                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.moviesTableView.reloadData()
                    self.moviesCollectionView.reloadData()
                    refreshControl.endRefreshing()
                    self.hideLoading()
                    print("Refresh finished")
                }
            }
        });
        task.resume()
    }

    // MARK: - Search

    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar;
    }

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredMovies = movies!.filter { movie in
            let title = movie["title"] as! String
            return title.lowercased().contains(searchText.lowercased())
        }

        moviesTableView.reloadData()
        moviesCollectionView.reloadData()
    }
    
    // MARK: - Reachability

    func isOnline(isOnline: Bool) {
         networkView.isHidden = isOnline
    }

    // MARK: - IBAction

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch viewTypeSegmentedControl.selectedSegmentIndex
        {
        case 0:
            moviesTableView.isHidden = false
            moviesCollectionView.isHidden = true
        case 1:
            moviesTableView.isHidden = true
            moviesCollectionView.isHidden = false
        default:
            break;
        }
    }
    
    // MARK: - HUD
    
    func showLoading() {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud!.label.text = "Updating movies..."
        hud!.contentColor = UIColor.white
        hud!.bezelView.color = UIColor.black
        self.view.addSubview(hud!)
    }
    
    func hideLoading() {
        hud?.removeFromSuperview()
    }

    // MARK: - Utils

    func numberOfItems() -> Int {
        if let movies = movies {

            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredMovies.count
            }
            return movies.count
        }
        else {
            return 0
        }
    }
    
    func movieAt(indexPath: IndexPath) -> NSDictionary {
        let movie: NSDictionary
        if searchController.isActive && searchController.searchBar.text != "" {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        return movie
    }
}

// MARK: - UITableViewDataSource

extension MoviesViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movieAt(indexPath: indexPath)
        
        let title = movie["title"] as? String
        cell.titleLabel.text = title
        
        let overview = movie["overview"] as? String
        cell.overviewLabel.text = overview
        
        let baseUrl = "http://image.tmdb.org/t/p/original"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = URL(string: baseUrl + posterPath)
            let imageRequest = URLRequest(url: imageUrl!)

            cell.movieImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    if imageResponse != nil {
                        cell.movieImageView.alpha = 0.0
                        cell.movieImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.movieImageView.alpha = 1.0
                        })
                    } else {
                        cell.movieImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // TODO: Implement error handling
                    print("Request failed")
            })
        }

        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }
}

extension MoviesViewController :  UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MovieCell
        let scaleTransform = CATransform3DMakeScale(1.4, 1.4, 1.4)
        cell.layer.transform = scaleTransform
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            cell.layer.transform = CATransform3DIdentity
        })
    }

    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    }
}
// MARK: - UICollectionViewDataSource

extension MoviesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell

        let baseUrl = "http://image.tmdb.org/t/p/original"

        let movie = self.movieAt(indexPath: indexPath)

        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = URL(string: baseUrl + posterPath)
            let imageRequest = URLRequest(url: imageUrl!)
            
            cell.movieImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    if imageResponse != nil {
                        cell.movieImageView.alpha = 0.0
                        cell.movieImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.movieImageView.alpha = 1.0
                        })
                    } else {
                        cell.movieImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // TODO: Implement error handling
                    print("Request failed")
            })
        }

        return cell
    }
}

extension MoviesViewController : UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
        let rotationTransform = CATransform3DMakeRotation(40, 20, 20, 20)
        cell.layer.transform = rotationTransform
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            cell.layer.transform = CATransform3DIdentity
        })
    }
}

// MARK: - UISearchResultsUpdating

extension MoviesViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

// MARK: - UITabBarControllerDelegate

extension MoviesViewController : UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        endpoint = (tabBarController.selectedIndex == 0) ? "now_playing" : "top_rated"
    }
}
