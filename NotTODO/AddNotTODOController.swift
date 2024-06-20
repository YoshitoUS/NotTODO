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
        
        // 通知の権限をリクエスト
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知の権限リクエストエラー: \(error)")
            } else {
                print("通知の権限が \(granted ? "許可されました" : "拒否されました")")
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PickerCell.self, forCellReuseIdentifier: "PickerCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        if let notTODO = notTODO {
            titleTextField.text = notTODO.title
        }

        // タップジェスチャーを追加してキーボードを閉じる
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }


    // キーボードを閉じるメソッド
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
                    notTODO.date = cell.datePicker1.date
                    notTODO.repeatUntil = cell.datePicker2.date
                    notTODO.hasNotification = cell.notificationSwitch.isOn
                }

                if cell.notificationSwitch.isOn {
                    print("通知をスケジュールします")
                    scheduleTimeNotification(for: notTODO, at: cell.datePicker1.date, until: cell.datePicker2.date)
                } else {
                    print("通知を削除します")
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
            cell.datePicker1.date = notTODO.date
            cell.datePicker2.date = notTODO.repeatUntil
            cell.notificationSwitch.isOn = notTODO.hasNotification
            cell.label.text = "通知"
            cell.datePicker1.isHidden = !notTODO.hasNotification
            cell.datePicker2.isHidden = !notTODO.hasNotification

            // 通知のオン/オフを切り替えるクロージャを設定
            cell.onNotificationSwitchChanged = { [weak self] isOn, date1, date2 in
                guard let self = self else { return }
                try! self.realm.write {
                    notTODO.hasNotification = isOn
                    notTODO.date = date1
                    notTODO.repeatUntil = date2
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
                    print("通知の追加に失敗しました: \(error)")
                } else {
                    print("通知がスケジュールされました: \(dateComponents)")
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
