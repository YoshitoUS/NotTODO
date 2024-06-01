import RealmSwift
import UIKit
import CoreLocation

class NotTODOViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var myManager: CLLocationManager!
    
    var notTODOs: Results<NotTODO>!
    let realm = try! Realm()
    
    var isEditingMode: Bool = false // 編集モードをトグルするためのプロパティ
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NotTODOTableViewCell", bundle: nil), forCellReuseIdentifier: "NotTODOCell")
        
        // Realmからデータを取得
        notTODOs = realm.objects(NotTODO.self)
        
        // デバッグ用にデータをログ出力
        print("Number of NotTODOs: \(notTODOs.count)")
        for notTODO in notTODOs {
            print("NotTODO: \(notTODO.title), Date: \(notTODO.date)")
        }
        
        myManager = CLLocationManager()
        myManager.delegate = self
        
        // 初回起動時に許可ステータスを確認
        checkLocationAuthorization()
    }
    
    @IBAction func toggleEditingMode(_ sender: Any) {
        isEditingMode = !isEditingMode
        tableView.setEditing(isEditingMode, animated: true)
    }
    
    // UITableViewDataSourceメソッドの実装
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notTODOs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotTODOCell", for: indexPath) as! NotTODOTableViewCell
        cell.notTODO = notTODOs[indexPath.row] // NotTODO モデルをセルにセット
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "AddReminderSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddReminderSegue" {
            let destinationVC = segue.destination as! AddNotTODOController
            if let indexPath = sender as? IndexPath {
                let selectedNotTODO = notTODOs[indexPath.row]
                destinationVC.notTODO = selectedNotTODO
            }
            destinationVC.onSave = { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notTODOToDelete = notTODOs[indexPath.row]
            let realm = try! Realm()
            try! realm.write {
                realm.delete(notTODOToDelete)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func checkLocationAuthorization() {
        switch myManager.authorizationStatus {
        case .notDetermined:
            myManager.requestWhenInUseAuthorization()
        case .restricted:
            alertMessage(message: "位置情報サービスの利用が制限されている利用できません。「設定」⇒「一般」⇒「機能制限」")
        case .denied:
            alertMessage(message: "位置情報の利用が許可されていないため利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」⇒「アプリ名」")
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                myManager.startUpdatingLocation()
            } else {
                alertMessage(message: "位置情報サービスがONになっていないため利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」")
            }
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func alertMessage(message: String) {
        let alertController = UIAlertController(title: "注意", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}
