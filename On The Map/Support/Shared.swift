//
//  Shared.swift
//  On The Map
//
//  Created by VIdushi Jaiswal on 11/11/17.
//  Copyright © 2017 Vidushi Jaiswal. All rights reserved.
//

import Foundation
import UIKit

class Shared: NSObject {
    
    //Errors
    class func alertUser(vc: UIViewController,title: String) {
        
            let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okayAction)
             vc.present(alertController, animated: true, completion: nil)
     
    }
    
    
    
    
}
