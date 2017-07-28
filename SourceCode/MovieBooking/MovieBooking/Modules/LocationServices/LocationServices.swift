//
//  LocationServices.swift
//  ChatApp
//
//  Created by Tam Nguyen Ngoc on 3/19/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

typealias locationServicesUpdateBlock =  (_ location: CLLocation?) -> Void
typealias locationServiceReverseGeocodeLocationBlock = (_ location: CLLocation, _ placemarks: [CLPlacemark], _ error: NSError?) -> Void
typealias locationServiceSearchPlaceBlock = (_ searchText: String, _ items: [MKMapItem], _ error: NSError?) -> Void

// Define value support for get geolocation from public ip. This service is limmted 10,000 request per hour
let kGeolocationServiceURL = "http://www.freegeoip.net/json"
let kLocationServicesPreviousSessionLocationUserDefaultKey = "kLocationServicesPreviousSessionLocationUserDefaultKey"

class LocationServices: NSObject, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager?
    private var didUpdateLocationBlocks = [String: locationServicesUpdateBlock]()
    
    var currentLocation: CLLocation? {
        didSet {
            // Save each time updated
            self.previousSessionLocation = self.currentLocation
        }
    }
    
    var previousSessionLocation: CLLocation? {
        get {
            let locationData = UserDefaults.standard.value(forKey: kLocationServicesPreviousSessionLocationUserDefaultKey) as? Data
            
            if locationData != nil {
                let location = NSKeyedUnarchiver.unarchiveObject(with: locationData!) as? CLLocation
                return location
            }
            
            return nil
        } set {
            // Save to NSUserDefault
            if newValue == nil {
                UserDefaults.standard.setValue(nil, forKey: kLocationServicesPreviousSessionLocationUserDefaultKey)
            } else {
                let data = NSKeyedArchiver.archivedData(withRootObject: newValue!)
                UserDefaults.standard.setValue(data, forKey: kLocationServicesPreviousSessionLocationUserDefaultKey)
            }
            
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: Class methods
    
    static let sharedInstance : LocationServices = {
        let instance = LocationServices()
        
        return instance
    }()
    
    // MARK: Override methods
    
    override init() {
        super.init()
        
        // Init location manager
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: Detection methods
    
    class func isLocationServiceEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    class func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    // MARK: Monitoring methods
    
    func startMonitorLocationUpdate() {
        if (!LocationServices.isLocationServiceEnabled()) {
            return
        }
        
        // On iOS 8, we need call methods request using location while using app
        if (LocationServices.authorizationStatus() == .notDetermined) {
            if #available(iOS 8.0, *) {
                self.locationManager!.requestWhenInUseAuthorization()
            } else {
                // Fallback on earlier versions
            }
            
            return
        }
        
        // Just call update location methods
        self.locationManager!.startUpdatingLocation()
    }
    
    func pauseMonitorLocationUpdate() {
        self.locationManager!.stopUpdatingLocation()
    }

    func didUpdateNewLocations(_ locations: [CLLocation]) {
        let location = locations[0]
        
        if (self.currentLocation == nil || (location.coordinate.longitude != self.currentLocation!.coordinate.longitude || location.coordinate.latitude != self.currentLocation!.coordinate.latitude)) {
            
            // Store new location
            self.currentLocation = location
            
            // Call all blocks handle
            for block in self.didUpdateLocationBlocks {
                block.1(location)
            }
        }
    }
    
    // MARK: Methods support for hanlder blocks
    
    /**
        Method to add new block to handle location did changed value
        
        - ownerObject: object is owner of this block handle
    */
    func addLocationUpdatedBlock(_ objectOwner: NSObject, block: @escaping locationServicesUpdateBlock) {
        let objectAddress = objectOwner.memoryAddressString()
        self.didUpdateLocationBlocks[objectAddress] = block
    }
    
    func removeLocationUpdatedBlock(_ objectOwner: NSObject) {
        let objectAddress = objectOwner.memoryAddressString()
        self.didUpdateLocationBlocks[objectAddress] = nil
    }
    
    func removeAllLocationUpdatedBlocks() {
        self.didUpdateLocationBlocks.removeAll(keepingCapacity: false)
    }
    
    // MARK: Methods support for detect geolocation info from public IP
    
    class func getGeolocationInfoFromPublicIP(_ completedBlock: @escaping (_ geolocationDict: NSDictionary?) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.default.qosClass).async(execute: { () -> Void in
            var responseDict: NSDictionary?
            let serviceURL = URL(string: kGeolocationServiceURL)
            
            if (serviceURL != nil) {
                let responseJsonString: String?
                
                do {
                    responseJsonString = try (NSString(contentsOf: serviceURL!, encoding: String.Encoding.utf8.rawValue) as String?)
                } catch _ {
                    responseJsonString = nil
                }
                
                if (responseJsonString != nil) {
                    // Parse response string to NSDictionary
                    responseDict = responseJsonString!.toJsonObject()
                }
            }
            
            // Call completed block
            DispatchQueue.main.async(execute: { () -> Void in
                completedBlock(responseDict)
            })
        })
    }
    
    // MARK:
    // MARK: Methods
    
    func reverseGeocodeLocation(_ location: CLLocation, completed: @escaping locationServiceReverseGeocodeLocationBlock) -> CLGeocoder {
        let geoCode = CLGeocoder()
        
        geoCode.reverseGeocodeLocation(location) { (placemarks, error) in
            var placemarksResult = [CLPlacemark]()
            
            if placemarks != nil {
                placemarksResult.append(contentsOf: placemarks!)
            }
            
            completed(location, placemarksResult, error as NSError?)
        }
        
        return geoCode
    }
    
    func searchPlaces(_ searchText: String!, region: MKCoordinateRegion, completed: @escaping locationServiceSearchPlaceBlock) -> MKLocalSearch {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        // Create search engine
        let searchEngine = MKLocalSearch(request: request)
        
        searchEngine.start { (response, error) in
            var resultItems = [MKMapItem]()
            
            if response != nil {
                resultItems.append(contentsOf: response!.mapItems)
            }
            
            // Callback
            completed(searchText, resultItems, error as NSError?)
        }
        
        return searchEngine
    }
    
    // MARK: CLLocationManager's delegates
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 8.0, *) {
            if (status == CLAuthorizationStatus.authorizedWhenInUse) {
                self.startMonitorLocationUpdate()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We should call blocks handle this changed on main queue
        DispatchQueue.main.async(execute: { () -> Void in
            self.didUpdateNewLocations(locations)
        })
    }
}
