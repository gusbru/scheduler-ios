//
//  SubjectDataSource.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-07.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit

class SubjectDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var subjectList: [String] = ["Select a Subject"]
    var selectedSubject: String = ""
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name("term selected"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("term selected"), object: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        subjectList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        subjectList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSubject = subjectList[row]
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        
        guard let data = notification.userInfo as? [String: String] else { return }
        
        if let selectedTerm = data["selectedTerm"] {
            print("get subjects from \(selectedTerm)")
        }
    }
    
}
