import Foundation
import UIKit

class UdacityClient {
    private static var session = URLSession.shared
    
    //MARK: UDACITY CLIENT
    
    static func login(username: String, password: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = Constants.url
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue(Constants.applicationResponse, forHTTPHeaderField: "Accept")
        request.addValue(Constants.applicationResponse, forHTTPHeaderField:  "Content-Type")
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task =  session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if error == nil {
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                parseJSONData(data: newData! as NSData, completionHandler: completionHandler)
            }  else {
                return completionHandler(nil, error! as NSError)
            }
            
        }
        task.resume()
        
        return task
        
    }
    
    
    static func getAccountData (account: String, completionHandler:@escaping (_ result: AnyObject?, _ error: NSError?)->Void)->URLSessionDataTask {
        let  request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(account)")!)
        let task =  session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if error != nil {
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            parseJSONData(data: newData! as NSData, completionHandler: completionHandler)
            
        }
        task.resume()
        return task
        
    }
    
    static func logout(completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?)-> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: Constants.url)! as URL)
        request.httpMethod = "DELETE"
        var cookieToken: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                cookieToken = cookie
            }
        }
        if let cookie = cookieToken {
            request.setValue(cookie.value, forHTTPHeaderField: "XSRF-TOKEN")
        }
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            parseJSONData(data: newData as NSData, completionHandler: completionHandler)
            
            
        }
        task.resume()
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
    
    
    
    //MARK: Helper functions - from the MyfavouriteMovies in class app
    
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
