//
//  TableViewController.swift
//  On The Map
//
//  Created by VIdushi Jaiswal on 02/11/17.
//  Copyright © 2017 Vidushi Jaiswal. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard StudentCollection.studentCollection.students.count != 0 else {
            Shared.alertUser(vc: self, title: "Download Failed")
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
            
            return
        }
    }

    
    // MARK: ACTIONS
    
    @IBAction func logout(sender: UIBarButtonItem) {
        UdacityClient.logout(completionHandler: { (result, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if error != nil {
                    print(error?.localizedDescription ?? "Error")
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            })
        })
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        tableView.reloadData()
    }
    
    // MARK: TABLE VIEW - data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentCollection.studentCollection.students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let student = StudentCollection.studentCollection.students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        cell.textLabel?.text =  "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mapString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let urlString = StudentCollection.studentCollection.students[indexPath.row].mediaURL
        if let url = URL(string:  urlString) {
            if UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
      
}
