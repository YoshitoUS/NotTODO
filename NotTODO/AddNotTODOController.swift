import UIKit
import RealmSwift

class AddNotTODOController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
  
    var onSave: (() -> Void)?
    
    @IBAction func saveNotTODO(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let date = datePicker.date
        let NotTODO = NotTODO(title: title, date: date)
        let realm = try! Realm()
        try! realm.write {
            realm.add(NotTODO)
        }
        onSave?()
        navigationController?.popViewController(animated: true)
    }
}


