import UIKit

class CheckBox: UIButton {
    // Images
    let checkedImage =  UIImage(systemName: "checkmark.circle.fill")?.withTintColor(UIColor(red: 115/255, green: 139/255, blue: 147/255, alpha: 1))
    let uncheckedImage =  UIImage(systemName: "circle.fill")?.withTintColor(UIColor(red: 115/255, green: 139/255, blue: 147/255, alpha: 1))
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
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
