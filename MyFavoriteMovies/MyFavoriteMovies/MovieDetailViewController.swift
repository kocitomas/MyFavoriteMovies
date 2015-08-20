//
//  MovieDetailViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var unFavoriteButton: UIButton!

    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var movie: Movie?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.titleLabel.text = self.movie!.title
        
        /* TASK A: Get favorite movies, then update the favorite buttons */
        /* 1A. Set the parameters */
        let userID = self.appDelegate.userID!
        let requestParameters = ["api_key":self.appDelegate.apiKey,"session_id":self.appDelegate.sessionID!,"page":1]
        /* 2A. Build the URL */
        let urlString = self.appDelegate.baseURLSecureString + "account/\(userID)/favorite/movies" + self.appDelegate.escapedParameters(requestParameters as! [String:AnyObject])
        let url = NSURL(string: urlString)!
        /* 3A. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        /* 4A. Make the request */
        let task = session.dataTaskWithRequest(request){data,response,downloadError in
            if let error = downloadError{
                dispatch_async(dispatch_get_main_queue()){
                    println("download error (favorite movies list)")
                }
            }
            else{
                /* 5A. Parse the data */
                let parsedResults  = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                let movieList = parsedResults["results"] as! [[String:AnyObject]]
                let movies = Movie.moviesFromResults(movieList)
                
                /* 6A. Use the data! */
                var movieIsFavorited: Bool = false
                for movie in movies{
                    if movie.id == self.movie!.id{
                        movieIsFavorited   = true
                    }
                }
                
                if movieIsFavorited{
                    dispatch_async(dispatch_get_main_queue()){
                        self.favoriteButton.hidden = true
                        self.unFavoriteButton.hidden = false
                    }
                }
                else{
                    dispatch_async(dispatch_get_main_queue()){
                        self.favoriteButton.hidden = false
                        self.unFavoriteButton.hidden = true
                    }
                }
            }
        }

        /* 7A. Start the request */
        task.resume()
        /* TASK B: Get the poster image, then populate the image view */
        if let posterPath = movie!.posterPath {
            
            /* 1B. Set the parameters */
            // There are none...
            
            /* 2B. Build the URL */
            let baseURL = NSURL(string: appDelegate.config.baseImageURLString)!
            let url = baseURL.URLByAppendingPathComponent("w342").URLByAppendingPathComponent(posterPath)
            
            /* 3B. Configure the request */
            let request = NSURLRequest(URL: url)
            
            /* 4B. Make the request */
            let task = session.dataTaskWithRequest(request) {data, response, downloadError in
                
                if let error = downloadError {
                    println(error)
                } else {
                    
                    /* 5B. Parse the data */
                    // No need, the data is already raw image data.
                    
                    /* 6B. Use the data! */
                    if let image = UIImage(data: data!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.posterImageView!.image = image
                        }
                    }
                }
            }
        
            /* 7B. Start the request */
            task.resume()
        }
    }
    
    // MARK: - Favorite Actions
    
    @IBAction func unFavoriteButtonTouchUpInside(sender: AnyObject) {
        
        /* TASK: Remove movie as favorite, then update favorite buttons */
        /* 1. Set the parameters */
        let userID = self.appDelegate.userID!
        let requestParameters = ["api_key":self.appDelegate.apiKey,"session_id":self.appDelegate.sessionID!]
        /* 2. Build the URL */
        let urlString = self.appDelegate.baseURLSecureString + "account/\(userID)/favorite" + self.appDelegate.escapedParameters(requestParameters)
        let url     = NSURL(string: urlString)!
        /* 3. Configure the request */
        let postRequest = NSMutableURLRequest(URL: url)
        postRequest.HTTPMethod = "POST"
        postRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        postRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.HTTPBody = "{\n  \"media_type\": \"movie\",\n  \"media_id\": \(self.movie!.id),\n  \"favorite\": false\n}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(postRequest){data,response,error in
            /* 5. Parse the data */
            if let error = error{
                dispatch_async(dispatch_get_main_queue()){
                    println("error during post request")
                }
            }
            /* 6. Use the data! */
            else{
                let parsedData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                if let statusCode = parsedData["status_code"] as? Int{
                    if statusCode == 13{
                        dispatch_async(dispatch_get_main_queue()){
                            self.favoriteButton.hidden = false
                            self.unFavoriteButton.hidden = true
                        }
                    }
                }
            }
        }

        /* 7. Start the request */
        task.resume()
    }
    
    @IBAction func favoriteButtonTouchUpInside(sender: AnyObject) {
        
        /* TASK: Remove movie as favorite, then update favorite buttons */
        /* 1. Set the parameters */
        let userID = self.appDelegate.userID!
        let requestParameters = ["api_key":self.appDelegate.apiKey,"session_id":self.appDelegate.sessionID!]
        /* 2. Build the URL */
        let urlString = self.appDelegate.baseURLSecureString + "account/\(userID)/favorite" + self.appDelegate.escapedParameters(requestParameters)
        let url     = NSURL(string: urlString)!
        /* 3. Configure the request */
        let postRequest = NSMutableURLRequest(URL: url)
        postRequest.HTTPMethod = "POST"
        postRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        postRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.HTTPBody = "{\n  \"media_type\": \"movie\",\n  \"media_id\": \(self.movie!.id),\n  \"favorite\": true\n}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(postRequest){data,response,error in
            /* 5. Parse the data */
            if let error = error{
                dispatch_async(dispatch_get_main_queue()){
                    println("error during post request")
                }
            }
                /* 6. Use the data! */
            else{
                let parsedData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                if let statusCode = parsedData["status_code"] as? Int{
                    if statusCode == 1 || statusCode == 12{
                        dispatch_async(dispatch_get_main_queue()){
                            self.favoriteButton.hidden = true
                            self.unFavoriteButton.hidden = false
                        }
                    }
                }
            }
        }
        /* 7. Start the request */
        task.resume()
    }
}