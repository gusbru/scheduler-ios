//
//  TermDataSource.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-07.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit
import CoreData

class TermDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var selectedTerm: String = ""
    var dataController: NSPersistentContainer!
    var fetchResultsController: NSFetchedResultsController<Term>!
    
    override init() {
        super.init()
        setupDataPersistence()
        subscribeNotifications()
    }
    
    deinit {
        unsubscribeNotifications()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return fetchResultsController.sections?.count ?? 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fetchResultsController.sections?[component].numberOfObjects ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let indexPath = IndexPath(row: row, section: component)
        let aTerm = fetchResultsController.object(at: indexPath)
        return aTerm.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath = IndexPath(row: row, section: component)
        let aTerm = fetchResultsController.object(at: indexPath)
        selectedTerm = aTerm.name ?? ""
        
        NotificationCenter.default.post(name: NSNotification.Name("term selected"), object: nil, userInfo: ["selectedTerm": selectedTerm])
    }
    
    private func subscribeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchTerms), name: NSNotification.Name(rawValue: "fetchTerms"), object: nil)
    }
    
    private func unsubscribeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "fetchTerms"), object: nil)
    }
    
}

// MARK:- Fetch Results Controller - Data Persistence
extension TermDataSource: NSFetchedResultsControllerDelegate{
    private func setupDataPersistence() {
        let dataController = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        self.dataController = dataController
        
        let fetchRequestTerm: NSFetchRequest<Term> = Term.fetchRequest()
        let sortDescriptorTerm = NSSortDescriptor(key: "id", ascending: true)
        fetchRequestTerm.sortDescriptors = [sortDescriptorTerm]
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequestTerm, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Cannot fetch terms \(error.localizedDescription)")
        }
        
        
        
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerWillChangeContent")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("inserted!")
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent")
    }
}

// MARK:- Fetch Results from Web
extension TermDataSource {
    // MARK:- Fetch Terms
    @objc fileprivate func fetchTerms() {
        SchedulerClient.getTerms { (response, error) in
            if let error = error {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchError"), object: nil, userInfo: ["errorMessage": error.localizedDescription])
                return
            }
            
            
            
            for term in response {
                
                var isNewTerm = true
                for savedTerm in self.fetchResultsController.fetchedObjects! {
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchTermFinished"), object: nil)
        }
    }
}
