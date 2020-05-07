//
//  MainViewController.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-07.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    var dataController: NSPersistentContainer!
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
                    let mainTabBarController = self.storyboard?.instantiateViewController(identifier: "MainTabBar") as! MainTabBarViewController
                    self.navigationController?.pushViewController(mainTabBarController, animated: true)
                }
            }
            return
        }
        
        // Token not valid or not present
        sleep(1)
        let loginViewController = storyboard?.instantiateViewController(identifier: "Login") as! LoginViewController
        navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    
    
    

    

}