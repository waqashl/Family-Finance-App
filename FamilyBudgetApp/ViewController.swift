//
//  ViewController.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 17/02/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password.isSecureTextEntry = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func signInBtnAction(_ sender: Any) {
        
        let activity = UIActivityIndicatorView(frame: self.view.frame)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        activity.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.view.addSubview(activity)
        var error = ""
        var errorDis = ""
        
        if emailAddress.text == "" {
            error = "Email Address cannot be empty"
        }
        else if password.text == "" || password.text!.characters.count < 6 {
            error = "Password error"
            errorDis = "Password cannot be less than 6 characters"
        }
        
        if error == "" {
            
            Auth.sharedInstance().signIn(email: emailAddress.text!, password: password.text!, callback: { (error) in
                if error != nil {
                    
                    let alert = UIAlertController(title: error?.localizedDescription, message: errorDis, preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    alert.addAction(action)
                    activity.stopAnimating()
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    activity.stopAnimating()
                    self.performSegue(withIdentifier: "home", sender: nil)
                    
                }
            })
        }
        else {
            
            let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            activity.stopAnimating()
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    

}

