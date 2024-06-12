import UIKit
import RealmSwift
import UserNotifications

class AddNotTODOController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!

    var onSave: (() -> Void)?
    var notTODO: NotTODO?

    let realm = try! Realm() // Realmインスタンスを追加

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PickerCell.self, forCellReuseIdentifier: "PickerCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

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
                    
                    // 時間部分のみを抽出
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: cell.datePicker.date)
                    if let hour = components.hour, let minute = components.minute {
                        // 今日の日付に時間を設定
                        let today = Date()
                        var todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
                        todayComponents.hour = hour
                        todayComponents.minute = minute
                        
                        if let timeDate = calendar.date(from: todayComponents) {
                            notTODO.repeatUntil = timeDate
                        }
                    }
                    
                    notTODO.hasNotification = cell.notificationSwitch.isOn
                }
                
                if cell.notificationSwitch.isOn {
                    scheduleTimeNotification(for: notTODO, at: cell.datePicker.date, until: notTODO.date)
                } else {
                    removeTimeNotification(for: notTODO)
                }
            }
        }
        
        onSave?()
        dismiss(animated: true, completion: nil)
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
                try! self.realm.write {
                    notTODO.hasNotification = isOn
                    notTODO.date = date
                    
                    // 時間部分のみを抽出
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: date)
                    if let hour = components.hour, let minute = components.minute {
                        // 今日の日付に時間を設定
                        let today = Date()
                        var todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
                        todayComponents.hour = hour
                        todayComponents.minute = minute
                        
                        if let timeDate = calendar.date(from: todayComponents) {
                            notTODO.repeatUntil = timeDate
                        }
                    }
                }
            }
        }
        return cell
    }

    private func scheduleTimeNotification(for notTODO: NotTODO, at date: Date, until endDate: Date) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = notTODO.title
        content.sound = UNNotificationSound.default
        
        var currentDate = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        while currentDate <= endDate {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.year = calendar.component(.year, from: currentDate)
            dateComponents.month = calendar.component(.month, from: currentDate)
            dateComponents.day = calendar.component(.day, from: currentDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Failed to add time notification: \(error)")
                }
            }
            
            // 次の日に設定
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    }

    private func removeTimeNotification(for notTODO: NotTODO) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
}
