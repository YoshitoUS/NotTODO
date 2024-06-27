import RealmSwift
import UIKit
import CoreLocation
import WidgetKit

class NotTODOViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var trashImage: UIImageView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var sengen: UIButton!
    @IBOutlet weak var sengenView: UIImageView!
    
    var notTODOs: Results<NotTODO>!
    let realm = NotTODO.realm
    
    var isEditingMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isEditingMode")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isEditingMode")
        }
    }
    
    // ボタンの画像をプロパティとして定義
    var isDeleteButtonToggled = false
    let deleteImage = UIImage(systemName: "trash.square.fill")
    let deleteImageToggled = UIImage(systemName: "trash.slash.square")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NotTODOTableViewCell", bundle: nil), forCellReuseIdentifier: "NotTODOCell")
        tableView.backgroundColor = UIColor.clear
        
        // Realmからデータを取得
        notTODOs = realm.objects(NotTODO.self)
        
        // デバッグ用にデータをログ出力
        print("Number of NotTODOs: \(notTODOs.count)")
        for notTODO in notTODOs {
            print("NotTODO: \(notTODO.title), Date: \(notTODO.date)")
        }
        
        // 通知の登録
        NotificationCenter.default.addObserver(self, selector: #selector(updatePercentage), name: NSNotification.Name("CheckChanged"), object: nil)
        updatePercentage()
        
        trashImage.image = deleteImage
        
        // 編集モードを復元
        tableView.setEditing(isEditingMode, animated: false)
        
        sengen.layer.cornerRadius = 8
        sengenView.layer.cornerRadius = 8
        sengenView.image = UIImage(systemName: "person.wave.2.fill")
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CheckChanged"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // カスタムカラーを定義
        let customColor1 = UIColor(red: 115/255, green: 139/255, blue: 147/255, alpha: 1)
        topView.backgroundColor = customColor1
        
        // ナビゲーションバーの設定
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = customColor1
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        } else {
            print("Navigation bar is not available")
        }
        
        plusButton.layer.cornerRadius = plusButton.frame.height / 2
        plusButton.layer.shadowOpacity = 0.7
        plusButton.layer.shadowRadius = 3
        plusButton.layer.shadowColor = UIColor.black.cgColor
        plusButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        //plusButton.clipsToBounds = true
        plusButton.backgroundColor = UIColor(red: 82/255, green: 190/255, blue: 198/255, alpha: 1)
        
    }
    
    @objc func updatePercentage() {
        let total = notTODOs.count
        let checked = notTODOs.filter("isChecked == true").count
        let percentage = total > 0 ? (Double(checked) / Double(total)) * 100 : 0
        let roundedPercentage = Int(round(percentage))
        
        let percentageString = "\(roundedPercentage)%"
        let attributedString = NSMutableAttributedString(string: " \(percentageString)")
        
        let percentageRange = (attributedString.string as NSString).range(of: "\(roundedPercentage)")
        let percentSignRange = (attributedString.string as NSString).range(of: "%")
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: percentageRange) // 数字のフォントサイズ
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20), range: percentSignRange) // %のフォントサイズ
        
        percentageLabel.attributedText = attributedString
        
    }
    
    @IBAction func toggleEditingMode(_ sender: Any) {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
        
        isDeleteButtonToggled.toggle()
        let image = isDeleteButtonToggled ? deleteImageToggled : deleteImage
        trashImage.image = image
    }
    
    // UITableViewDataSourceメソッドの実装
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notTODOs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotTODOCell", for: indexPath) as! NotTODOTableViewCell
        let notTODO = notTODOs[indexPath.row]
        cell.notTODO = notTODO // セルにモデルをセット
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
                self?.updatePercentage()
                // ウィジェットのタイムラインをリロード
                WidgetCenter.shared.reloadTimelines(ofKind: "NotTODOWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "NotTODOLockScreenWidget")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notTODOToDelete = notTODOs[indexPath.row]
            try! realm.write {
                realm.delete(notTODOToDelete)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updatePercentage()
            // ウィジェットのタイムラインをリロード
            WidgetCenter.shared.reloadTimelines(ofKind: "NotTODOWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "NotTODOLockScreenWidget")
        }
    }
    
    // 写真にして共有
    @IBAction func captureAndShareTableView(_ sender: Any) {
        if let tableViewImage = tableView.toImage() {
            let titledImage = addTitleToImage(image: tableViewImage, title: "NotTODO List")
            showShareSheet(image: titledImage, sender: sender)
        }
    }
    
    private func showShareSheet(image: UIImage, sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController {
            if let barButtonItem = sender as? UIBarButtonItem {
                popoverController.barButtonItem = barButtonItem
            } else if let view = sender as? UIView {
                popoverController.sourceView = view
                popoverController.sourceRect = view.bounds
            } else {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            popoverController.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true, completion: nil)
    }
    
    private func addTitleToImage(image: UIImage, title: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width, height: image.size.height + 50))
        return renderer.image { context in
            // 元の画像を描画
            image.draw(at: CGPoint(x: 0, y: 50))
            
            // タイトルの属性を定義
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            // タイトルを描画する位置を計算
            let titleSize = title.size(withAttributes: attributes)
            let titleRect = CGRect(x: (image.size.width - titleSize.width) / 2, y: 10, width: titleSize.width, height: titleSize.height)
            
            // タイトルを描画
            title.draw(in: titleRect, withAttributes: attributes)
        }
    }
}


extension UITableView {
    func toImage() -> UIImage? {
        let originalBounds = self.bounds
        
        let renderer = UIGraphicsImageRenderer(size: self.contentSize)
        let image = renderer.image { context in
            let savedContentOffset = self.contentOffset
            let savedFrame = self.frame
            let savedBounds = self.bounds
            
            self.contentOffset = .zero
            self.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
            self.bounds = CGRect(origin: .zero, size: self.contentSize)
            
            self.layer.render(in: context.cgContext)
            
            self.contentOffset = savedContentOffset
            self.frame = savedFrame
            self.bounds = savedBounds
        }
        
        self.bounds = originalBounds
        return image
    }
}

/*
 extension UITableView {
 func toImage() -> UIImage? {
 let originalOffset = self.contentOffset
 let contentHeight = self.contentSize.height
 let frameHeight = self.frame.size.height
 
 // Set the table view's height to content height
 self.contentSize.height = contentHeight
 self.frame.size.height = contentHeight
 
 // Render the image
 let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
 let image = renderer.image { context in
 self.layer.render(in: context.cgContext)
 }
 
 // Restore the original offset and frame height
 self.contentOffset = originalOffset
 self.frame.size.height = frameHeight
 
 return image
 }
 }
 */
