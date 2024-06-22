import UIKit
import RealmSwift
import UserNotifications

class AddNotTODOController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bellImageView: UIImageView!
    @IBOutlet weak var datePicker1: UIDatePicker!
    @IBOutlet weak var datePicker2: UIDatePicker!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!
    
    var onNotificationSwitchChanged: ((Bool, Date, Date) -> Void)?

    var onSave: (() -> Void)?
    var notTODO: NotTODO?

    let realm = try! Realm() // Realmインスタンスを追加

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

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
            try! realm.write {
                notTODO.date = datePicker1.date
                notTODO.repeatUntil = datePicker2.date
                notTODO.hasNotification = notificationSwitch.isOn
            }

            if notificationSwitch.isOn {
                scheduleTimeNotification(for: notTODO, at: datePicker1.date, until: datePicker2.date)
            } else {
                removeTimeNotification(for: notTODO)
            }
        }

        onSave?()
        dismiss(animated: true, completion: nil)
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
    
    private func setupViews() {
        // デバッグ用コード
        if datePicker1 == nil {
            print("datePicker1 is nil")
        } else {
            print("datePicker1 is connected")
        }

        if datePicker2 == nil {
            print("datePicker2 is nil")
        } else {
            print("datePicker2 is connected")
        }

        if notificationSwitch == nil {
            print("notificationSwitch is nil")
        } else {
            print("notificationSwitch is connected")
        }

        // datePicker1の設定
        datePicker1.preferredDatePickerStyle = .inline
        datePicker1.datePickerMode = .date
        datePicker1.isHidden = true
        datePicker1.isUserInteractionEnabled = true
        datePicker1.addTarget(self, action: #selector(datePicker1Changed), for: .valueChanged)

        // datePicker2の設定
        datePicker2.preferredDatePickerStyle = .wheels
        datePicker2.datePickerMode = .time
        datePicker2.isHidden = true
        datePicker2.isUserInteractionEnabled = true

        // notificationSwitchの設定
        notificationSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    @objc private func switchChanged() {
        let isOn = notificationSwitch.isOn
        datePicker1.isHidden = !isOn
        datePicker2.isHidden = !isOn
        onNotificationSwitchChanged?(isOn, datePicker1.date, datePicker2.date)

        // デバッグログの追加
        print("Date Picker 1 is \(datePicker1.isHidden ? "hidden" : "visible"), user interaction enabled: \(datePicker1.isUserInteractionEnabled)")
        print("Date Picker 2 is \(datePicker2.isHidden ? "hidden" : "visible"), user interaction enabled: \(datePicker2.isUserInteractionEnabled)")
    }

    @objc private func datePicker1Changed() {
        print("Date selected: \(datePicker1.date)")
    }
}
