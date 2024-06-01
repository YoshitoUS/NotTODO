import UIKit
import RealmSwift
import UserNotifications

class AddNotTODOController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var onSave: (() -> Void)?
    var notTODO: NotTODO? // 編集するNotTODOのオブジェクト
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // notTODOのデータを使ってビューを更新
        if let notTODO = notTODO {
            titleTextField.text = notTODO.title
            datePicker.date = notTODO.date
        }
    }
    
    @IBAction func saveNotTODO(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let date = datePicker.date
        let realm = try! Realm()
        
        try! realm.write {
            if let notTODO = notTODO {
                // 既存のnotTODOを更新
                notTODO.title = title
                notTODO.date = date
            } else {
                // 新しいnotTODOを作成
                let newNotTODO = NotTODO()
                newNotTODO.title = title
                newNotTODO.date = date
                realm.add(newNotTODO)
                notTODO = newNotTODO
            }
        }
        
        onSave?()
        dismiss(animated: true, completion: nil)
        
        // 通知の設定
        let content = UNMutableNotificationContent()
        content.title = "NotTODO"
        content.body = title
        content.sound = UNNotificationSound.default
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let identifier = "MyNotification_\(title)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
}
