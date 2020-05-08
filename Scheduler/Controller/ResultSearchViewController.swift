//
//  ResultSearchViewController.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit

class ResultSearchViewController: UIViewController {
    
    var term: String?
    var subject: String?
    
    @IBOutlet weak var listTableView: UITableView!
    
    
    var classList: [ListResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listTableView.delegate = self
        listTableView.dataSource = self
        
        // Fetch Data
        guard let term = term else { return }
        guard let subject = subject else { return }
        SchedulerClient.getList(term: term, subject: subject) { (response, error) in
            if let error = error {
                self.displayAlert(message: error.localizedDescription)
                return
            }
            
            self.classList = response
            self.listTableView.reloadData()
        }
        
    }
    
    
    // MARK: - Alert
    private func displayAlert(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

    

}


extension ResultSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(classList.count)
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellList", for: indexPath) as! ListTableViewCell
        
        // format cell
        cell.numbeOfCreditsLabel.text = classList[indexPath.row].numberOfCredits
        cell.subjectTitleLabel.text = "\(classList[indexPath.row].courseNumber)-\(classList[indexPath.row].courseTitle)"
        
        
        return cell
    }
    
    
}
