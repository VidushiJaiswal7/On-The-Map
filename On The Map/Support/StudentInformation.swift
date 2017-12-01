//
//  StudentInformation.swift
//  On The Map
//
//  Created by VIdushi Jaiswal on 01/11/17.
//  Copyright © 2017 Vidushi Jaiswal. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var dictionary: [String: AnyObject] {
        return [
            "firstName" : firstName as AnyObject,
            "lastName" : lastName as AnyObject,
            "latitude" : latitude as AnyObject,
            "longitude" : longitude as AnyObject,
            "mapString" : mapString as AnyObject,
            "mediaURL" : mediaURL as AnyObject,
        ]
    }
    
   
    //ensuring that value is not nil - took help from the udacity forums
    init?(dictionary: [String: AnyObject]){
        guard
        let uniqueKey = dictionary["uniqueKey"] as? String,
        let firstName = dictionary["firstName"] as? String,
        let lastName  = dictionary["lastName"] as? String,
        let latitude  = dictionary["latitude"] as? Double,
        let longitude = dictionary["longitude"] as? Double,
        let mapString = dictionary["mapString"] as? String,
        let mediaURL  = dictionary["mediaURL"] as? String
        else  {
            return nil
        }
        

        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
    }

}
