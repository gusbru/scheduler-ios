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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    
    // MARK:- Button Actions
    @IBAction func login(_ sender: Any) {
        handleLoginSuccess()
    }
    
    @IBAction func signIn(_ sender: Any) {
        handleSignIn()
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

