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
    
//    var termsList: [String] = ["Select a Term"]
    var selectedTerm: String = ""
    var fetchResultsController: NSFetchedResultsController<Term>!
    
    
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
}

// MARK:- Fetch Results Controller Delegate
extension TermDataSource: NSFetchedResultsControllerDelegate{
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
