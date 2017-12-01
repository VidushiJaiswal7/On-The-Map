//
//  PostingInformationViewController.swift
//  On The Map
//
//  Created by VIdushi Jaiswal on 02/11/17.
//  Copyright © 2017 Vidushi Jaiswal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PostingInformationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate  {

    private var mapView = MKMapView()
    private var isSubmitTime = false
    private let geoCoder = CLGeocoder()
    private var changedLocation = false
    private var mapString = String()
    private var coord = CLLocation()
    
    @IBOutlet weak var infoTextView: UITextField!
    
  
    @IBOutlet weak var findAndSubmit: UIButton!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var question: UIStackView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //DELEGATES
        mapView.delegate = self
        infoTextView.delegate = self
   
        
        //MAPVIEW
        //Second View
        
         mapView = MKMapView(frame: CGRect(x: 0, y: view.frame.height/3 , width: 500, height: view.frame.height/2))
        
        self.view.addSubview(mapView)
        mapView.isHidden = true
        
        
        //Making the navbar invisible - used stackoverflow answer.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else if UIDevice.current.orientation.isPortrait {
            print("Potrait")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
   
    //MARK: METHODS
    
    
    func findOnMap() {
        //Presenting the second view
        unsubscribeFromKeyboardNotifications()
        mapView.isHidden = false
        cancel.tintColor = UIColor.white
        self.infoTextView.transform = CGAffineTransform(translationX: 0, y: -150)
        infoTextView.text = "Enter A Link To Share Here"
        infoTextView.resignFirstResponder()
        findAndSubmit.setTitle("Finish", for: .normal)
        
        //Hiding the first view
        question.isHidden = true
        isSubmitTime = true
    }
    
    func submitInfo() {
        if let account = StudentCollection.studentCollection.myAccount {
            let firstName = account[Constants.firstName] as! String
            let lastName = account[Constants.lastName] as! String
         
            var dictionary: [String: AnyObject] {
                return [
                    "uniqueKey": "OPTIONAL" as AnyObject,
                    "firstName" : firstName as AnyObject,
                    "lastName" : lastName as AnyObject,
                    "latitude" :  coord.coordinate.latitude as AnyObject,
                    "longitude" : coord.coordinate.longitude as AnyObject,
                    "mapString" : mapString as AnyObject,
                    "mediaURL" : infoTextView.text as AnyObject,
                ]
            }
            
             let student = StudentInformation(dictionary: dictionary)
          
            findAndSubmit.setTitle("POSTING", for: .normal)
            
            ParseClient.postInfo(student: student!, completionHandler: { (result, error) -> Void in
                
                if error != nil {
                    return Shared.alertUser(vc: self,title: error!.localizedDescription)
                }else if result != nil {
                    self.dismiss(animated: true, completion: nil)
                }else {
                    return Shared.alertUser(vc: self, title: "Error in posting to the network")
                }
            })
      
        }
    }
    
    @IBAction func findAndSubmit(sender: UIButton) {
        if isSubmitTime {
            submitInfo()
        } else {
            if changedLocation || (infoTextView.text?.contains("ENTER A LOCATION HERE"))!{
                geocodeString()
            } else {
                findOnMap()
            }
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
   
   

    
    // MARK: GET CURRENT LOCATION
    //Took help from a github repository and stack overflow to geocode location.

    func geocodeString() {
       
        
        if let mapString = infoTextView.text{
            print(mapString)
            //Took help from stackoverflow to add the indicator view
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            view.addSubview(activityIndicator)
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y)
            activityIndicator.startAnimating()
            
            geoCoder.geocodeAddressString(mapString, completionHandler: {(placemarks, error) -> Void in
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                guard error == nil else {
                    Shared.alertUser(vc: self, title: "Sorry, location not found.")
                    return
                }
                
                if let placeMark = placemarks?.first {
                    self.makeAnnotation(currLoc: placeMark.location!)
                    self.mapString = mapString
                    self.coord = placeMark.location!
                    self.findOnMap()
                }
            })

        }
    }
    
  
    
    
    // MARK: ANNOTATIONS
    
    func makeAnnotation(currLoc: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: currLoc.coordinate.latitude, longitude: currLoc.coordinate.longitude)
        self.mapView.setRegion(MKCoordinateRegion(center: currLoc.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1), longitudeDelta: CLLocationDegrees(1))), animated: true)
        self.mapView.addAnnotations([annotation])
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.pinTintColor = .blue
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    
    //MARK: TEXTVIEW DELEGATE
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == infoTextView {
            changedLocation = true
            if textField.text == "Enter A Link To Share Here" {
                textField.text = "http://"
            }else{
                textField.text = ""
            }
        }
    }
    
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Notifications
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    //MARK: Helper Functions - so that the keyboard does not hide the text.
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if infoTextView.isFirstResponder
        {
            
            self.view.frame.origin.y =  getKeyboardHieght(notification) * -1
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if infoTextView.isFirstResponder
        {
            self.view.frame.origin.y = 0
        }
    }
    
    
    func getKeyboardHieght(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
        
    }
    
    
}

