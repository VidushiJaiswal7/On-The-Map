//
//  StudentCollection.swift
//  On The Map
//
//  Created by VIdushi Jaiswal on 01/11/17.
//  Copyright © 2017 Vidushi Jaiswal. All rights reserved.
//

import Foundation
//Took help from a github repository
class StudentCollection: NSObject {
    
    static let studentCollection = StudentCollection()
    var students = [StudentInformation]()
    var myAccount:NSDictionary?
    
    
    func getInfo (array: [[String: AnyObject]]) {
        students.removeAll()
        for dictionary in array {
            let student = StudentInformation(dictionary: dictionary)
            if student != nil {
            students.append(student!)
            }
            
    }
}
}


