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
    let realm = try! Realm() // Realmインスタンスを追加

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        
        try! realm.write {
            if let notTODO = notTODO {
                notTODO.title = title
            } else {
                let newNotTODO = NotTODO()
                newNotTODO.title = title
                realm.add(newNotTODO)
                notTODO = newNotTODO
            }
        }
        
        if let notTODO = notTODO {
            let indexPath = IndexPath(row: 0, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? PickerCell {
                try! realm.write {
                    notTODO.date = cell.datePicker.date
                    notTODO.hasNotification = cell.notificationSwitch.isOn
                }
                
                if cell.notificationSwitch.isOn {
                    scheduleTimeNotification(for: notTODO, at: cell.datePicker.date)
                } else {
                    removeTimeNotification(for: notTODO)
                }
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
            cell.label.text = "通知"
            cell.datePicker.isHidden = !notTODO.hasNotification
            
            // 通知のオン/オフを切り替えるクロージャを設定
            cell.onNotificationSwitchChanged = { [weak self] isOn, date in
                guard let self = self else { return }
                notTODO.hasNotification = isOn
                notTODO.date = date
            }
        }
        return cell
    }

    private func scheduleTimeNotification(for notTODO: NotTODO, at date: Date) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "NotTODO"
        content.body = notTODO.title
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TimeNotification_\(notTODO.id.stringValue)", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to add time notification: \(error)")
            }
        }
    }

    private func removeTimeNotification(for notTODO: NotTODO) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["TimeNotification_\(notTODO.id.stringValue)"])
    }
}
