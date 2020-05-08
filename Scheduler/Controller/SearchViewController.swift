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
    var fetchResultsController: NSFetchedResultsController<CourseSection>!

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
        
        termPickerView.dataSource = termDataSource
        termPickerView.delegate = termDataSource
        subjectPickerView.dataSource = subjectDataSource
        subjectPickerView.delegate = subjectDataSource
        
        // subscribe notifications
        NotificationCenter.default.addObserver(self, selector: #selector(startLoadSubjects), name: NSNotification.Name(rawValue: "startGetSubjects"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endLoadingSubjects), name: NSNotification.Name(rawValue: "endGetSubjects"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectedSubject(_:)), name: NSNotification.Name(rawValue: "subjectSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectedTerm(_:)), name: NSNotification.Name(rawValue: "term selected"), object: nil)
        
        // disable search button
        searchButton.isEnabled = false
        
        // setup data persistence
        setupDataPersistence()
        
        loadingSpinner.startAnimating()
        SchedulerClient.getTerms { (response, error) in
            if let error = error {
                self.loadingSpinner.stopAnimating()
                self.displayAlert(message: error.localizedDescription)
                return
            }
            
            
            for term in response {
                self.termDataSource.termsList.append(term.termName)
            }
            self.termPickerView.reloadAllComponents()
            self.loadingSpinner.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "startGetSubjects"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "endGetSubjects"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "subjectSelected"), object: nil)
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
    
    // MARK: - Handle Notifications
    
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
    
    private func setupDataPersistence() {
        let dataController = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        self.dataController = dataController
        
        let fetchRequest: NSFetchRequest<CourseSection> = CourseSection.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Cannot fetch subjects \(error.localizedDescription)")
        }
        
    }
}

extension SearchViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
