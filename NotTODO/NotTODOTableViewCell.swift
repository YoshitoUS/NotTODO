import UIKit
import RealmSwift

class NotTODOTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkBox: CheckBox!
    
    var notTODO: NotTODO? {
        didSet {
            guard let notTODO = notTODO else { return }
            titleLabel.text = notTODO.title
            checkBox.notTODO = notTODO
            checkBox.setChecked(notTODO.isChecked)
            checkBox.onCheckChanged = { [weak self] isChecked in
                guard self != nil else { return }
                let realm = NotTODO.realm
                try! realm.write {
                    notTODO.isChecked = isChecked
                }
                NotificationCenter.default.post(name: NSNotification.Name("CheckChanged"), object: nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellAppearance()
    }
    
    private func setupCellAppearance() {
        // セルの背景色を設定
        self.backgroundColor = UIColor.white
        
        // セルの角を丸く設定
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
