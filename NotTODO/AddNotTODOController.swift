import UIKit
import RealmSwift
import UserNotifications
import CoreLocation

class AddNotTODOController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!

    var onSave: (() -> Void)?
    var notTODO: NotTODO?

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(PickerCell.self, forCellReuseIdentifier: "PickerCell")
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        if let notTODO = notTODO {
            titleTextField.text = notTODO.title
        }
    }

    @IBAction func saveNotTODO(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let realm = try! Realm()
        
        try! realm.write {
            if let notTODO = notTODO {
                notTODO.title = title
                if let location = currentLocation {
                    notTODO.latitude = location.coordinate.latitude
                    notTODO.longitude = location.coordinate.longitude
                }
            } else {
                let newNotTODO = NotTODO()
                newNotTODO.title = title
                if let location = currentLocation {
                    newNotTODO.latitude = location.coordinate.latitude
                    newNotTODO.longitude = location.coordinate.longitude
                }
                realm.add(newNotTODO)
                notTODO = newNotTODO
            }
        }
        
        onSave?()
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! PickerCell
        if let notTODO = notTODO {
            cell.datePicker.date = notTODO.date
            cell.notificationSwitch.isOn = notTODO.hasNotification
            cell.label.text = notTODO.title
            cell.datePicker.isHidden = !notTODO.hasNotification
        }
        return cell
    }
}
