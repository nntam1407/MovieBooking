//
//  CountryManager.swift
//  AskApp
//
//  Created by Tam Nguyen Ngoc on 9/1/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

let kGetCountryInformationURL = "http://ip-api.com/json"
let kPreviousCountryCodeUserDefaultKey = "kPreviousCountryCodeUserDefaultKey"

class CountryManager: NSObject {
    
    private var _allCountries = [CountryData]()
    private var _supportedCountries = [CountryData]()
    private var allPhoneCodes: [String: String]? // all phone codes in plist file
    
    var currentCountry: CountryData? = nil {
        didSet {
            self.countryCodeInUserDefault = self.currentCountry?.countryCode
        }
    }
    
    private var countryCodeInUserDefault: String? {
        get {
            return UserDefaults.standard.value(forKey: kPreviousCountryCodeUserDefaultKey) as? String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: kPreviousCountryCodeUserDefaultKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var allCountries: [CountryData] {
        return self._allCountries
    }
    
    var supportedCountries: [CountryData] {
        return self._supportedCountries
    }
    
    // MARK: Class methods
    
    static let sharedInstance : CountryManager = {
        let instance = CountryManager()
        
        return instance
    }()
    
    // MARK: Override methods
    
    override init() {
        super.init()
        
        // Load all phone code
        let filePath = Bundle.main.path(forResource: "PhoneCode", ofType: "plist")
        self.allPhoneCodes = NSDictionary(contentsOfFile: filePath!) as? [String: String]
        
        // Get all country in system setting
        let ISOCountryCodes = Locale.isoRegionCodes
        
        for countryCode in ISOCountryCodes {
            let phoneCode = self.allPhoneCodes![countryCode.uppercased()]
            
            if (phoneCode != nil) {
                let countryData = CountryData(countryCode: countryCode, phoneCode: phoneCode!)
                self._allCountries.append(countryData)
            }
        }
        
        // Try to get country from previous update
        if (self.countryCodeInUserDefault != nil) {
            self.currentCountry = self.getCountry(self.countryCodeInUserDefault!)
        }
    }
    
    // MARK: Methods
    
    func setSupportedCountryCodes(_ codes: [String]) {
        self._supportedCountries.removeAll()
        
        for code in codes {
            let country = self.getCountry(code)
            
            if country != nil {
                self._supportedCountries.append(country!)
            }
        }
        
        // If current country is not in supported country, we should reset it
        if self.currentCountry != nil && self._supportedCountries.count > 0 {
            if self._supportedCountries.contains(self.currentCountry!) {
                self.currentCountry = self._supportedCountries[0];
            }
        }
    }
    
    /*!
    * This will be response current country of this device
    * Now, we will detect via IP
    * This method is only fetch if before user does not choose any country
    * @param forceFetch: Force fetch no mater what
    */
    func fetchCurrentCountrySync(_ forceFetch: Bool, timeoutInterval: TimeInterval) -> (country: CountryData?, error: NSError?) {
        
        if (self.currentCountry != nil && !forceFetch) {
            return (self.currentCountry!, nil)
        }
        
        var jsonData: NSDictionary? = nil
        
        let request = URLRequest(url: URL(string: kGetCountryInformationURL)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: timeoutInterval)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let responseData = data {
                let dataString = String(data: responseData, encoding: String.Encoding.utf8)
                jsonData = dataString?.toJsonObject()
            } else {
                DLog("Cannot load country data from API")
                
                // Try get country info from system setting
                // Default get current country via System setting
                let systemCountryCode = Locale.current.localizedString(forRegionCode: Locale.current.regionCode!)?.uppercased()
                
                if (systemCountryCode != nil) {
                    self.currentCountry = self.getCountry(systemCountryCode!)
                }
            }
            
            // Signal semaphore
            semaphore.signal()
        })
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if (jsonData != nil) {
            let countryCode = jsonData!.stringValueNotNull("countryCode").uppercased()
            self.currentCountry = self.getCountry(countryCode)
            
            return (self.currentCountry!, nil)
        } else {
            return (nil, NSError(domain: "askApp", code: -1, userInfo: nil))
        }
    }
    
    func fetchCurrentCountryAsync(_ forceFetch: Bool,
        timeoutInterval: TimeInterval,
        completed: ((_ country: CountryData?, _ error: NSError?) -> Void)?) {
        
        DispatchQueue.global(qos: DispatchQoS.default.qosClass).async { () -> Void in
            let result = self.fetchCurrentCountrySync(forceFetch, timeoutInterval: timeoutInterval)
            
            DispatchQueue.main.async(execute: { () -> Void in
                completed?(result.country, result.error)
            })
        }
    }
    
    func getCountry(_ countryCode: String) -> CountryData? {
        for country in self._allCountries {
            if (country.countryCode!.uppercased() == countryCode.uppercased()) {
                return country
            }
        }
        
        return nil
    }
    
    func getCountry(phoneCode code: String) -> CountryData? {
        for country in self._allCountries {
            if (country.phoneCode == code) {
                return country
            }
        }
        
        return nil
    }
}
