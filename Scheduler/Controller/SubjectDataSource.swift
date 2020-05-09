//
//  SubjectDataSource.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-07.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit
import CoreData

class SubjectDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var selectedSubject: String = ""
    var dataController: NSPersistentContainer!
    var fetchResultsController: NSFetchedResultsController<Subject>?
    var term: Term?
    
    override init() {
        super.init()
//        setupeDataPersistence()
        subscribeNotifications()
    }
    
    deinit {
        unsubscribeNotifications()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return fetchResultsController?.sections?.count ?? 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fetchResultsController?.sections?[component].numberOfObjects ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let indexPath = IndexPath(row: row, section: component)
        let aSubject = fetchResultsController?.object(at: indexPath)
        return aSubject?.name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let indexPath = IndexPath(row: row, section: component)
        let aSubject = fetchResultsController?.object(at: indexPath)
        if let subject = aSubject?.name {
            selectedSubject = subject
            
            NotificationCenter.default.post(name: NSNotification.Name("subjectSelected"), object: nil, userInfo: ["selectedSubject": selectedSubject])
        }
    }
    
    // MARK:- Notifications
    private func subscribeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name("term selected"), object: nil)
    }
    
    private func unsubscribeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("term selected"), object: nil)
    }
    
    // MARK: Data Persistence
    private func setupeDataPersistence(currentTerm: Term) {
        let dataController = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        self.dataController = dataController
        
        let fetchRequest: NSFetchRequest<Subject> = Subject.fetchRequest()
        
        // predicate
        let predicate = NSPredicate(format: "term == %@", currentTerm)
        fetchRequest.predicate = predicate
        
        // sort
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController?.delegate = self
        
        do {
            try fetchResultsController?.performFetch()
        } catch {
            fatalError("Cannot fetch subjects \(error.localizedDescription)")
        }
    }
    
    // MARK:- Notification Handler
    @objc func onDidReceiveData(_ notification: Notification) {
        
        guard let data = notification.userInfo as? [String: Term] else { return }
        
        if let selectedTerm = data["selectedTerm"] {
            
            if (selectedTerm.name == "Select a Term") { return }
            
            // Related term
            if self.term == nil {
                self.term = selectedTerm
                setupeDataPersistence(currentTerm: selectedTerm)
            }
            
            
            // send notification - start load subjects
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startGetSubjects"), object: nil)
            
            SchedulerClient.getSubject(term: selectedTerm.name!) { (response, error) in
                if let error = error {
                    print(error)
                    // send notification to SearchViewController to display the error
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "errorFetchingSubjects"), object: nil, userInfo: ["errorMessage": error.localizedDescription])
                }
                
                for subject in response {
                    var isNewSubject = true
                    for savedSubject in self.fetchResultsController!.fetchedObjects! {
                        if savedSubject.name == subject.name {
                            isNewSubject = false
                            break
                        }
                    }
                    
                    
                    if isNewSubject {
                        // subject not found on memory --> save it
                        do {
                            // create a Subject object
                            let newSubject = Subject(context: self.dataController!.viewContext)
                            newSubject.id = subject.id
                            newSubject.name = subject.name
                            newSubject.code = subject.code
                            newSubject.term = self.term! 
                            
                            try self.dataController?.viewContext.save()
                        } catch {
                            print("error saving term \(error.localizedDescription)")
                        }
                    }
                    
                }

                // send notification - end loading
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "endGetSubjects"), object: nil)
            }
            
            
        }
    }
    
    
}

// MARK:- Fetch Result Controller Delegate
extension SubjectDataSource: NSFetchedResultsControllerDelegate {
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
