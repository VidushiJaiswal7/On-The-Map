//
//  MapViewController.swift
//  On The Map
//
//  Created by VIdushi Jaiswal on 02/11/17.
//  Copyright © 2017 Vidushi Jaiswal. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    private var annotations = [MKAnnotation]()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        //DELEGATES
       mapView.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRequestedData()
    }
    
    func getRequestedData() {
        if annotations.count == 0 {
            ParseClient.getRequestedData(completionHandler: { (success, error) -> Void in
                guard error == nil && success == true else {
                    DispatchQueue.main.async(execute: { () -> Void in
                       Shared.alertUser(vc: self, title: "Download Failed.")
                        
                    })
                    return
                }
            })
            
            for student in StudentCollection.studentCollection.students {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
                annotation.title = "\(student.firstName) \(student.lastName)"
                annotation.subtitle = student.mediaURL
                annotations.append(annotation)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.mapView.addAnnotations(self.annotations)
            })
        }
    }

  
   
    // MARK : ACTIONS
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        getRequestedData()
    }
    
    
    @IBAction func logout(sender: UIBarButtonItem) {
        //Took help from stackoverflow to add the activity indicator view
        let activityView = UIActivityIndicatorView()
        activityView.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(activityView)
        activityView.startAnimating()
        
        UdacityClient.logout(completionHandler: { (result, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                }
                else {
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        })
    }
    
    // MARK: MKMAPVIEW DELEGATE FUNCTIONS
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        } else {
            pinView?.annotation = annotation
            
        }
        return pinView
    }
    
  
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let urlString = view.annotation!.subtitle! {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                }
            }
            else {
                let alertController = UIAlertController(title: "URL does not exist", message: "", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        getRequestedData()
    }
    
}
