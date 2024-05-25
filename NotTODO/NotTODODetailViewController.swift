//
//  NotTODODetailViewController.swift
//  NotTODO
//
//  Created by Yoshito Usui on 2024/05/25.
//

import UIKit

class NotTODODetailViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var reminder: NotTODO?
    var onSave: ((NotTODO) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let reminder = reminder {
            titleTextField.text = reminder.title
            datePicker.date = reminder.date
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        if var reminder = reminder {
            reminder.title = titleTextField.text ?? ""
            reminder.date = datePicker.date
            onSave?(reminder)
            navigationController?.popViewController(animated: true)
        }
    }
}
