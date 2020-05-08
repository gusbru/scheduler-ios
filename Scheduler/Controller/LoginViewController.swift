//
//  ViewController.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-05.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    
    // MARK:- Button Actions
    @IBAction func login(_ sender: Any) {
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
        
        SchedulerClient.login(email: email, password: password) { (success, error) in
            if !success {
                
                self.displayAlert(message: error?.localizedDescription ?? "Something went wrong :(")
                self.setupLogin(isLoading: false)
                return
            }
            
            self.handleLoginSuccess()
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        handleSignIn()
    }
    
    private func setupLogin(isLoading: Bool) {
        if isLoading {
            loadingSpinner.startAnimating()
        } else {
            loadingSpinner.stopAnimating()
        }
        
        loginButton.isEnabled = !isLoading
        signInButton.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
    }
    
    private func displayAlert(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func handleLoginSuccess() {
        let mainTabBarController = storyboard?.instantiateViewController(identifier: "MainTabBar") as! MainTabBarViewController
        navigationController?.pushViewController(mainTabBarController, animated: true)
    }
    
    private func handleSignIn() {
        let signInViewController = storyboard?.instantiateViewController(identifier: "SignIn") as! SignInViewController
        navigationController?.pushViewController(signInViewController, animated: true)
    }
}

