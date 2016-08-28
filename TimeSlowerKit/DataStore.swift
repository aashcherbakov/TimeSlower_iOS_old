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
        let path = NSBundle(identifier: "oneLastDay.TimeSlowerKit")!.pathForResource("ISOCodes", ofType: "txt")
        let ISOCodes: NSString?
        do {
            ISOCodes = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            ISOCodes = nil
        }
        
        var dictionary = [String:String]()
        let components = ISOCodes!.componentsSeparatedByString("\r")
        
        for str in components {
            let countryData = str.componentsSeparatedByString("/")
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
        let bundle = NSBundle(identifier: "oneLastDay.TimeSlowerKit")
        let path = bundle!.pathForResource("LifeExpacity2013", ofType: "txt")
        let contentsOfFile: NSString?
        do {
            contentsOfFile = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            contentsOfFile = nil
        }
        let countryLines = contentsOfFile?.componentsSeparatedByString("\n") as [String]!
        
        var allCountries = [String:[String:String]]()
        for string in countryLines {
            if string != "" {
                let countryData = string.componentsSeparatedByString("/")
                let countryDataDictionary = ["Average": countryData[2], "Male": countryData[3], "Female": countryData[5]]
                let countryName = countryData[1]
                allCountries[countryName] = countryDataDictionary
            }
        }
        return allCountries
    }
    
}