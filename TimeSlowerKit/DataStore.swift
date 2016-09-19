//
//  DataStore.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

/**
 *  Struct responsible for retrieving life expectacy data from included documents.
 */
internal struct DataStore {
    
    /**
     Reads ISOCodes file and returns a dictionary with keys for country names and values as codes
     
     - returns: [String:String]
     */
    func countryCodesDictionary() -> [String:String] {
        let path = Bundle(identifier: "oneLastDay.TimeSlowerKit")!.path(forResource: "ISOCodes", ofType: "txt")
        let ISOCodes: NSString?
        do {
            ISOCodes = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
        } catch _ as NSError {
            ISOCodes = nil
        }
        
        var dictionary = [String:String]()
        let components = ISOCodes!.components(separatedBy: "\r")
        
        for str in components {
            let countryData = str.components(separatedBy: "/")
            dictionary[countryData[1]] = countryData[0]
        }
        
        return dictionary
    }
    
    /**
     Reads LifeExpacity2013 file and returns dictionary with countries as keys and values for 
     life expacity for man and woman
     
     - returns: [String:[String:String]]
     */
    func lifeExpacityDictionary() -> [String:[String:String]] {
        let bundle = Bundle(identifier: "oneLastDay.TimeSlowerKit")
        let path = bundle!.path(forResource: "LifeExpacity2013", ofType: "txt")
        let contentsOfFile: NSString?
        do {
            contentsOfFile = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
        } catch _ as NSError {
            contentsOfFile = nil
        }
        let countryLines = contentsOfFile?.components(separatedBy: "\n") as [String]!
        
        var allCountries = [String:[String:String]]()
        for string in countryLines! {
            if string != "" {
                let countryData = string.components(separatedBy: "/")
                let countryDataDictionary = ["Average": countryData[2], "Male": countryData[3], "Female": countryData[5]]
                let countryName = countryData[1]
                allCountries[countryName] = countryDataDictionary
            }
        }
        return allCountries
    }
    
}
