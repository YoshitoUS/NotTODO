//
//  AddNotTODO.swift
//  NotTODO
//
//  Created by Yoshito Usui on 2024/05/24.
//

import UIKit

class AddNotTODOController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var onSave: ((NotTODO) -> Void)?
    
    @IBAction func saveNotTODO(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let date = datePicker.date
        let NotTODO = NotTODO(title: title, date: date)
        onSave?(NotTODO)
        navigationController?.popViewController(animated: true)
    }
}


