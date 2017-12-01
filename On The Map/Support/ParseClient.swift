//
//  ParseClient.swift
//  On The Map
//
//  Created by VIdushi Jaiswal on 11/11/17.
//  Copyright © 2017 Vidushi Jaiswal. All rights reserved.
//

import Foundation

class ParseClient {
    private static var session = URLSession.shared
    
    static func getRequestedData (completionHandler: @escaping (_ success: Bool?, _ error: NSError?)->Void)->URLSessionDataTask {
        //https://parse.udacity.com/parse/classes/StudentLocation
        let params = ["limit": 100,"order":"-updatedAt"] as [String : Any]
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation\(escapedParameters(parameters: params as [String : AnyObject]))")! as URL)
        request.addValue(Constants.parseAppID, forHTTPHeaderField: Constants.appIDHeader)
        request.addValue(Constants.restApiKey, forHTTPHeaderField: Constants.apiKeyHeader)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                return completionHandler(false,error as NSError?)
            }
            
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                return completionHandler(false, nil)
            }
            
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                guard let array = dictionary["results"] as? [[String: AnyObject]] else {
                    return
                }
                completionHandler(true,nil)
                StudentCollection.studentCollection.getInfo(array: array)
                
            }catch{
                print("ERROR IN GETTING JSON OBJECT")
            }
        }
        task.resume()
        return task
    }
    
    static func postInfo (student: StudentInformation, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?)-> Void)->URLSessionDataTask {
        let request = NSMutableURLRequest(url: URL(string: Constants.urlLocation)!)
        request.httpMethod = "POST"
        request.addValue(Constants.parseAppID, forHTTPHeaderField: Constants.appIDHeader)
        request.addValue(Constants.restApiKey, forHTTPHeaderField: Constants.apiKeyHeader)
        request.addValue(Constants.applicationResponse, forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                return completionHandler(nil, nil)
            }
            if error != nil {
                return completionHandler(nil, error! as NSError)
            }
            ParseClient.parseJSONData(data: data! as NSData, completionHandler: completionHandler)
        }
        task.resume()
        return task
    }
    
    static func parseJSONData(data: NSData, completionHandler: (_ result: AnyObject?, _ error: NSError?)-> Void){
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject
        }catch{
            let userInfo = [NSLocalizedDescriptionKey: "\(data)"]
            completionHandler(nil, NSError(domain: "parseJSONData", code: 1, userInfo: userInfo))
        }
        completionHandler(parsedResult, nil)
    }
    
    
    //MARK: Helper functions -  from the MyfavouriteMovies in class app
    
    static func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
}
