//
//  LoginViewController.swift
//  On The Map
//
//  Created by VIdushi Jaiswal on 01/11/17.
//  Copyright © 2017 Vidushi Jaiswal. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: OUTLETS
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signUp: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reference - stackoverflow
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            DispatchQueue.main.async(execute: { () -> Void in
            Shared.alertUser(vc: self, title: "Internet connection not available! Make sure the device is connected to internet")
                 self.login.setTitle("Login", for: .normal)
            })
        }
        
        
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        userName.text = ""
        password.text = ""
    }
    
    //MARK: ACTIONS
    
    @IBAction func login(sender: UIButton) {
        guard let username = userName.text, username != "", let passWord = password.text, passWord != "" else {
            Shared.alertUser(vc: self, title:"Missing Username/Password")
            return
        }
        
        login.setTitle("Logging In...", for: .normal)
        let activityView = UIActivityIndicatorView()
        activityView.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(activityView)
        activityView.startAnimating()
      
        
       UdacityClient.login(username: username, password: passWord) { JSONResult,error in
     
            if let results = JSONResult as? NSDictionary {
                if let account = results[Constants.account] as? [String: AnyObject] {
                    if let account = account[Constants.key] as? String {
                        UdacityClient.getAccountData(account: account, completionHandler: { (result, error) -> Void in
                            if let userAccount = result![Constants.user] as? NSDictionary {
                                StudentCollection.studentCollection.myAccount = userAccount
                            }
                        })
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.login.setTitle("Login", for: .normal)
                            print("Login Successful")
                            activityView.stopAnimating()
                            activityView.removeFromSuperview()
                            self.performSegue(withIdentifier: "login", sender: self)
                            
                        })
                        
                    }
                } else {
                 
                    DispatchQueue.main.async(execute: { () -> Void in
                        Shared.alertUser(vc: self, title: "Password/Username Incorrect")
                        
                        self.login.setTitle("Login", for: .normal)
                    })
                    
                    
            
                }
            } else  {
                
                DispatchQueue.main.async(execute: {
                    Shared.alertUser(vc: self, title: (error?.localizedDescription)!)
                     self.login.setTitle("Login", for: .normal)
                })
               
                
            }
        }
    }
    
    @IBAction func signUp(sender: UIButton) {
        let url = URL(string: Constants.signUpUrl )
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
  
    
    //MARK: TEXTFIELD DELEGATE FUNCTIONS
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

