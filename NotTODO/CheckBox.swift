import UIKit
import RealmSwift
import WidgetKit

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(UIColor(red: 115/255, green: 139/255, blue: 147/255, alpha: 1))
    let uncheckedImage = UIImage(systemName: "circle.fill")?.withTintColor(UIColor(red: 115/255, green: 139/255, blue: 147/255, alpha: 1))
    
    var notTODO: NotTODO? {
        didSet {
            guard let notTODO = notTODO else { return }
            isChecked = notTODO.isChecked
            updateImage()
        }
    }
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            updateImage()
            if let notTODO = notTODO {
                let realm = NotTODO.realm
                try! realm.write {
                    notTODO.isChecked = isChecked
                }
                NotificationCenter.default.post(name: NSNotification.Name("CheckChanged"), object: nil)
                // ウィジェットのタイムラインをリロード
                WidgetCenter.shared.reloadTimelines(ofKind: "NotTODOWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "NotTODOLockScreenWidget")
            }
        }
    }
    
    var onCheckChanged: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        isChecked = !isChecked
        onCheckChanged?(isChecked)
    }
    
    private func updateImage() {
        if isChecked {
            self.setImage(checkedImage, for: .normal)
        } else {
            self.setImage(uncheckedImage, for: .normal)
        }
    }
    
    func setChecked(_ check: Bool) {
        isChecked = check
    }
}

extension UIImage {
    func withTintColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        let drawRect = CGRect(origin: .zero, size: size)
        withRenderingMode(.alwaysTemplate).draw(in: drawRect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage ?? self
    }
}
