import UIKit

class PickerCell: UITableViewCell {
    let datePicker = UIDatePicker()
    let label = UILabel()
    let notificationSwitch = UISwitch()
    let bell = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }

    @objc func datePickerValueDidChange(sender: UIDatePicker) {
        label.text = PickerCell.formatter.string(from: sender.date)
    }

    @objc func notificationSwitchChanged(sender: UISwitch) {
        let isOn = sender.isOn
        datePicker.isHidden = !isOn
        bell.image = isOn ? UIImage(systemName: "bell.fill") : UIImage(systemName: "bell")
    }

    private func prepare() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.isHidden = true
        datePicker.alpha = 1
        datePicker.isUserInteractionEnabled = true  // 確認ポイント
        
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
            
            notificationSwitch.leadingAnchor.constraint(equalTo: bell.trailingAnchor, constant: 10),
            notificationSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: notificationSwitch.trailingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            datePicker.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
        
        label.textColor = .black  // カラー設定
        datePicker.tintColor = .black  // カラー設定
    }

    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
}
