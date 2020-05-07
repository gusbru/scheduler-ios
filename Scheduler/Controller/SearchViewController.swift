//
//  SearchViewController.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var termPickerView: UIPickerView!
    @IBOutlet weak var subjectPickerView: UIPickerView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var searchButton: UIButton!
    
    var termDataSource = TermDataSource()
    var subjectDataSource = SubjectDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        termPickerView.dataSource = termDataSource
        termPickerView.delegate = termDataSource
        subjectPickerView.dataSource = subjectDataSource
        subjectPickerView.delegate = subjectDataSource
        
        // subscribe notifications
        NotificationCenter.default.addObserver(self, selector: #selector(startLoadSubjects), name: NSNotification.Name(rawValue: "startGetSubjects"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endLoadingSubjects), name: NSNotification.Name(rawValue: "endGetSubjects"), object: nil)
        
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
    }
    

    @IBAction func search(_ sender: Any) {
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
}


