import UIKit
import RealmSwift
import UserNotifications
import CoreLocation

class AddNotTODOController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationLabel: UILabel!
    
    var onSave: (() -> Void)?
    var notTODO: NotTODO? // 編集するNotTODOのオブジェクト
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // notTODOのデータを使ってビューを更新
        if let notTODO = notTODO {
            titleTextField.text = notTODO.title
            datePicker.date = notTODO.date
            locationLabel.text = "Location: \(notTODO.latitude), \(notTODO.longitude)"
        }
    }
    
    @IBAction func saveNotTODO(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let date = datePicker.date
        let realm = NotTODO.realm
        
        try! realm.write {
            if let notTODO = notTODO {
                // 既存のnotTODOを更新
                notTODO.title = title
                notTODO.date = date
                if let location = currentLocation {
                    notTODO.latitude = location.coordinate.latitude
                    notTODO.longitude = location.coordinate.longitude
                }
            } else {
                // 新しいnotTODOを作成
                let newNotTODO = NotTODO()
                newNotTODO.title = title
                newNotTODO.date = date
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
        
        // 通知の設定
        if let notTODO = notTODO {
            scheduleTimeNotification(for: notTODO)
            scheduleLocationNotification(for: notTODO)
        }
    }
    
    // CLLocationManagerDelegate メソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        if let location = currentLocation {
            locationLabel.text = "Location: \(location.coordinate.latitude), \(location.coordinate.longitude)"
        }
    }
    
    private func scheduleTimeNotification(for notTODO: NotTODO) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "NotTODO"
        content.body = notTODO.title
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notTODO.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TimeNotification_\(notTODO.id.stringValue)", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to add time notification: \(error)")
            }
        }
    }
    
    private func scheduleLocationNotification(for notTODO: NotTODO) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "NotTODO"
        content.body = notTODO.title
        content.sound = UNNotificationSound.default
        
        let coordinate = CLLocationCoordinate2D(latitude: notTODO.latitude, longitude: notTODO.longitude)
        let region = CLCircularRegion(center: coordinate, radius: 100, identifier: "LocationNotification_\(notTODO.id.stringValue)")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(identifier: "LocationNotification_\(notTODO.id.stringValue)", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to add location notification: \(error)")
            }
        }
    }
}
