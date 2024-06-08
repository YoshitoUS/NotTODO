import UIKit

class PickerCell: UITableViewCell {
    let datePicker = UIDatePicker()
    let label = UILabel()
    let notificationSwitch = UISwitch()
    let bell = UIImageView(image: UIImage(systemName: "bell")) // 初期画像を設定
    
    var onNotificationSwitchChanged: ((Bool, Date) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }

    @objc func datePickerValueDidChange(sender: UIDatePicker) {
        // 以前の機能を廃止
    }

    @objc func notificationSwitchChanged(sender: UISwitch) {
        let isOn = sender.isOn
        datePicker.isHidden = !isOn
        bell.image = isOn ? UIImage(systemName: "bell.fill") : UIImage(systemName: "bell")
        
        // 通知の設定/削除
        onNotificationSwitchChanged?(isOn, datePicker.date)

        // contentViewの高さを変更する
        UIView.animate(withDuration: 0.3) {
            self.contentView.layoutIfNeeded()
        }
    }

    private func prepare() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.isHidden = true
        datePicker.alpha = 1
        datePicker.isUserInteractionEnabled = true
        
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged(sender:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(datePickerValueDidChange(sender:)), for: .valueChanged)
        
        contentView.addSubview(label)
        contentView.addSubview(notificationSwitch)
        contentView.addSubview(bell)
        contentView.addSubview(datePicker)
        
        // Set up Auto Layout constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        notificationSwitch.translatesAutoresizingMaskIntoConstraints = false
        bell.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            bell.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bell.widthAnchor.constraint(equalToConstant: 30),
            bell.heightAnchor.constraint(equalToConstant: 30),
            
            label.leadingAnchor.constraint(equalTo: bell.trailingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            notificationSwitch.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            notificationSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            datePicker.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        label.text = "通知"
        label.textColor = .black
        datePicker.tintColor = .black
    }
}
