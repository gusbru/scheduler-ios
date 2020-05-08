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
    var dataController: NSPersistentContainer?
    var fetchTermResultsController: NSFetchedResultsController<Term>!
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
        handleDelegateAndDataSource()
        
        subscribeNotifications()
        
        // disable search button
        searchButton.isEnabled = false
        subjectPickerView.isUserInteractionEnabled = false
        subjectPickerView.alpha = 0.5
        loadingSpinner.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        // setup data persistence
        setupDataPersistence()
        
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
    
    private func cleanViewStack() {
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
    }
    
    
    // MARK:- Data Persistence
    private func setupDataPersistence() {
        let dataController = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        self.dataController = dataController
        
        let fetchRequestTerm: NSFetchRequest<Term> = Term.fetchRequest()
        let sortDescriptorTerm = NSSortDescriptor(key: "id", ascending: true)
        fetchRequestTerm.sortDescriptors = [sortDescriptorTerm]
        fetchTermResultsController = NSFetchedResultsController(fetchRequest: fetchRequestTerm, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchTermResultsController.delegate = termDataSource
        termDataSource.fetchResultsController = fetchTermResultsController
        do {
            try fetchTermResultsController.performFetch()
        } catch {
            fatalError("Cannot fetch terms \(error.localizedDescription)")
        }
        
        
        
        
    }
    
    // MARK:- Notifications
    fileprivate func subscribeNotifications() {
        // subscribe notifications
        NotificationCenter.default.addObserver(self, selector: #selector(startLoadSubjects), name: NSNotification.Name(rawValue: "startGetSubjects"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endLoadingSubjects), name: NSNotification.Name(rawValue: "endGetSubjects"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectedSubject(_:)), name: NSNotification.Name(rawValue: "subjectSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectedTerm(_:)), name: NSNotification.Name(rawValue: "term selected"), object: nil)
    }
    
    fileprivate func unsubscribeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "startGetSubjects"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "endGetSubjects"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "subjectSelected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "term selected"), object: nil)
    }
    
    // MARK:- handle delegate and data source
    private func handleDelegateAndDataSource() {
        termPickerView.dataSource = termDataSource
        termPickerView.delegate = termDataSource
        subjectPickerView.dataSource = subjectDataSource
        subjectPickerView.delegate = subjectDataSource
    }
    
    // MARK:- Fetch Terms
    fileprivate func fetchTerms() {
        SchedulerClient.getTerms { (response, error) in
            if let error = error {
                self.loadingSpinner.stopAnimating()
                self.displayAlert(message: error.localizedDescription)
                return
            }
            
            
            
            for term in response {
                
                var isNewTerm = true
                for savedTerm in self.fetchTermResultsController.fetchedObjects! {
                    if savedTerm.name == term.termName {
                        isNewTerm = false
                        break
                    }
                }
                
                
                if isNewTerm {
                    // term not found on memory --> save it
                    print("term not found on memory --> save it")
                    do {
                        // create a Term object
                        let newTerm = Term(context: self.dataController!.viewContext)
                        newTerm.id = term.id
                        newTerm.name = term.termName
                        try self.dataController?.viewContext.save()
                    } catch {
                        print("error saving term \(error.localizedDescription)")
                    }
                }
                
                
            }
            self.termPickerView.reloadAllComponents()
            self.loadingSpinner.stopAnimating()
        }
    }
    
    
}

