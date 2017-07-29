//
//  Defines.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/12/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

let kExampleURLString = "http://www.example.com"
let kBookingTicketSiteURL = "http://www.cathaycineplexes.com.sg/movies/"

// MARK: Define for web services
let kWebServiceBaseURL = "http://api.themoviedb.org/3"
let kWebServiceAPIKey = "72e1fa1c95f89c594d41508239ae15fd"
let kWebServiceImageRootURL = "http://image.tmdb.org/t/p/"

let kAppName = "MovieBooking"
let kAppStoreURL = "https://itunes.apple.com/us/app/cloud-music-player-offline-playlist-and-mp3-song/id1155922368?ls=1&mt=Z"
let kAppSupportEmail = "nntam1407@gmail.com"

// MARK: Define for core data

let kCoreDataSQLFileName = "moviebooking.sqlite"
let kCoreDataModelFileName = "moviebooking"
let kCoreDataModelFileExtension = "momd"

// MARK: Define for all global notifications keys
let kNotificationUpdateLocalizedText = "kNotificationUpdateLocalizedText"

// MARK: UI's Apperances
let kDefaultBarTintColor = 0x2196F3
let kDefaultButtonTintColor = 0x2891f7

// MARK: Addition info in app

let kPasswordMiniumLenght = 6
let kMaxUploadImageSize: CGFloat = 1024.0
