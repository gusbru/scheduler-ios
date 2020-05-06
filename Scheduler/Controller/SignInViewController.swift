//
//  SignInViewController.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = false
    }
    

    @IBAction func signIn(_ sender: Any) {
        guard let name = nameTextField.text else {
            displayAlert(message: "Invalid name")
            return
        }
        
        guard let email = emailTextField.text else {
            displayAlert(message: "Invalid email")
            return
        }
        
        guard let password = passwordTextField.text else {
            displayAlert(message: "Invalid password")
            return
        }
        
        if email.isEmpty || password.isEmpty {
            displayAlert(message: "Email/password invalid")
            return
        }
        
        setupLogin(isLoading: true)
        
        SchedulerClient.signIn(name: name, email: email, password: password) { (success, error) in
            if !success {
                self.displayAlert(message: error?.localizedDescription ?? "Something went wrong :(")
                self.setupLogin(isLoading: false)
                return
            }
            
            self.handleSignInSuccess()
        }
    }
    
    private func handleSignInSuccess() {
        let mainTabBarController = storyboard?.instantiateViewController(identifier: "MainTabBar") as! MainTabBarViewController
        navigationController?.pushViewController(mainTabBarController, animated: true)
    }
    
    
    private func setupLogin(isLoading: Bool) {
        if isLoading {
            loadingSpinner.startAnimating()
        } else {
            loadingSpinner.stopAnimating()
        }
        
        signInButton.isEnabled = !isLoading
        nameTextField.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
    }
    
    private func displayAlert(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}
