//
//  TermDataSource.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-07.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit

class TermDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var termsList: [String] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return termsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return termsList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("make a request for \(termsList[row])")
    }
}
