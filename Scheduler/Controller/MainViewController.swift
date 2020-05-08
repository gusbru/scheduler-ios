//
//  MainViewController.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-07.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLogin()
    }
    
    private func checkLogin() {
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            
            // check if token is valid
            SchedulerClient.checkToken(token: token) { (success, error) in
                if success {
                    self.goToSearch()
                }
                
                if error != nil {
                    self.goToLogin()
                }
            }
            
        } else {
            // Token not valid or not present
            sleep(1)
            goToLogin()
        }
        
        
        
    }
    
    
    func goToLogin() {
        let loginViewController = storyboard?.instantiateViewController(identifier: "Login") as! LoginViewController
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func goToSearch() {
        let mainTabBarController = storyboard?.instantiateViewController(identifier: "MainTabBar") as! MainTabBarViewController
        navigationController?.pushViewController(mainTabBarController, animated: true)
    }
    

}
