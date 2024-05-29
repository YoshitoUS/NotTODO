import RealmSwift
import UIKit

class NotTODOViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var notTODOs: Results<NotTODO>!
    let realm = try! Realm()
     //var NotTODOs: [NotTODO] = [] // NotTODOはカスタムモデル
    
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
    }
    
    // UITableViewDataSourceメソッドの実装
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notTODOs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotTODOCell", for: indexPath) as! NotTODOTableViewCell
        let notTODO = notTODOs[indexPath.row]
        cell.titleLabel.text = notTODO.title
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "AddReminderSegue" {
               let destinationVC = segue.destination as! AddNotTODOController
               destinationVC.onSave = { [weak self] /*reminder*/ in
                   /*self?.NotTODOs.append(reminder)*/
                   self?.tableView.reloadData()
               }
           }
       }
}


