//
//  ViewController.swift
//  NotTODO
//
//  Created by Yoshito Usui on 2024/05/24.
//

import UIKit

class NotTODOViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var NotTODOs: [NotTODO] = [] // NotTODOはカスタムモデル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // UITableViewDataSourceメソッドの実装
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotTODOs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotTODOCell", for: indexPath) as! NotTODOTableViewCell
        let NotTODO = NotTODOs[indexPath.row]
        cell.titleLabel.text = NotTODO.title
        cell.dateLabel.text = NotTODO.date.description
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "AddReminderSegue" {
               let destinationVC = segue.destination as! AddNotTODOController
               destinationVC.onSave = { [weak self] reminder in
                   self?.NotTODOs.append(reminder)
                   self?.tableView.reloadData()
               }
           }
       }
}


