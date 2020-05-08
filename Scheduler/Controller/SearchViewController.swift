//
//  SearchViewController.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    var selectedTerm: String?
    var selectedSubject: String?
    var fetchSubjectResultsController: NSFetchedResultsController<Subject>!

    @IBOutlet weak var termPickerView: UIPickerView!
    @IBOutlet weak var subjectPickerView: UIPickerView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    var termDataSource = TermDataSource()
    var subjectDataSource = SubjectDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cleanViewStack()
        
        // setup delegate and data source for picker views
        setupDelegateAndDataSource()
        
        subscribeNotifications()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        // fetch terms
        fetchTerms()
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeNotifications()
    }
    

    @IBAction func search(_ sender: Any) {
        guard let selectedTerm = selectedTerm else { return }
        guard let selectedSubject = selectedSubject else { return }
        
        let resultSearchViewController = storyboard?.instantiateViewController(identifier: "ResultSearch") as! ResultSearchViewController
        resultSearchViewController.term = selectedTerm
        resultSearchViewController.subject = selectedSubject
        
        navigationController?.pushViewController(resultSearchViewController, animated: true)
        
    }
    
    @IBAction func clear(_ sender: Any) {
    }
    
    @IBAction func logout(_ sender: Any) {
        SchedulerClient.clearUserInfo()
        let loginViewController = storyboard?.instantiateViewController(identifier: "Login") as! LoginViewController
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    
    // MARK:- Alert
    
    private func displayAlert(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Notifications Handlers
    
    @objc func startLoadSubjects() {
        loadingSpinner.startAnimating()
        termPickerView.isUserInteractionEnabled = false
        termPickerView.alpha = 0.5
    }
    
    @objc func endLoadingSubjects() {
        loadingSpinner.stopAnimating()
        subjectPickerView.reloadAllComponents()
    }
    
    @objc func handleSelectedTerm(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let selectedTerm = userInfo["selectedTerm"] {
            self.selectedTerm = selectedTerm as? String
            subjectPickerView.isUserInteractionEnabled = true
            subjectPickerView.alpha = 1.0
        }
        
    }
    
    @objc func handleSelectedSubject(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let selectedSubject = userInfo["selectedSubject"] {
            self.selectedSubject = selectedSubject as? String
        }
        
        if self.selectedTerm != nil && self.selectedSubject != nil {
            searchButton.isEnabled = true
        }
        
    }
    
    @objc func handleFetchError(_ notificaton: Notification) {
        loadingSpinner.stopAnimating()
        displayAlert(message: notificaton.userInfo!["errorMessage"] as? String ?? "Erro fetching Terms")
    }
    
    @objc func handleFetchTermFinished() {
        termPickerView.reloadAllComponents()
        loadingSpinner.stopAnimating()
    }
    
    private func cleanViewStack() {
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
    }
    
    
    
    // MARK:- Notifications
    fileprivate func subscribeNotifications() {
        // subscribe notifications
        NotificationCenter.default.addObserver(self, selector: #selector(startLoadSubjects), name: NSNotification.Name(rawValue: "startGetSubjects"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endLoadingSubjects), name: NSNotification.Name(rawValue: "endGetSubjects"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectedSubject(_:)), name: NSNotification.Name(rawValue: "subjectSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectedTerm(_:)), name: NSNotification.Name(rawValue: "term selected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFetchError(_:)), name: NSNotification.Name(rawValue: "fetchError"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFetchTermFinished), name: NSNotification.Name(rawValue: "fetchTermFinished"), object: nil)
    }
    
    fileprivate func unsubscribeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "startGetSubjects"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "endGetSubjects"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "subjectSelected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "term selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "fetchError"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "fetchTermFinished"), object: nil)
    }
    
    // MARK:- handle delegate and data source
    private func setupDelegateAndDataSource() {
        termPickerView.dataSource = termDataSource
        termPickerView.delegate = termDataSource
        subjectPickerView.dataSource = subjectDataSource
        subjectPickerView.delegate = subjectDataSource
    }
    
    // MARK:- Fetch Terms
    fileprivate func fetchTerms() {
        searchButton.isEnabled = false
        subjectPickerView.isUserInteractionEnabled = false
        subjectPickerView.alpha = 0.5
        loadingSpinner.startAnimating()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchTerms"), object: nil)
    }
    
    
}

