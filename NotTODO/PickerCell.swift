import UIKit

class PickerCell: UITableViewCell {
    let bellImageView = UIImageView()
    let datePicker = UIDatePicker()
    let notificationSwitch = UISwitch()
    let label = UILabel()
    
    var onNotificationSwitchChanged: ((Bool, Date) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        bellImageView.image = UIImage(systemName: "bell")
        bellImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bellImageView)
        
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .dateAndTime
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.isHidden = true // 初期状態で非表示
        contentView.addSubview(datePicker)
        
        notificationSwitch.translatesAutoresizingMaskIntoConstraints = false
        notificationSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        contentView.addSubview(notificationSwitch)
        
        label.text = "通知"
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Bell image constraints
            bellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            bellImageView.widthAnchor.constraint(equalToConstant: 24),
            bellImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Label constraints
            label.leadingAnchor.constraint(equalTo: bellImageView.trailingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: bellImageView.centerYAnchor),
            
            // Notification switch constraints
            notificationSwitch.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16),
            notificationSwitch.centerYAnchor.constraint(equalTo: bellImageView.centerYAnchor),
            notificationSwitch.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            // Date picker constraints
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker.topAnchor.constraint(equalTo: bellImageView.bottomAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    @objc private func switchChanged() {
        let isOn = notificationSwitch.isOn
        datePicker.isHidden = !isOn
        onNotificationSwitchChanged?(isOn, datePicker.date)
        
        // レイアウトを更新してdatePickerの表示を切り替える
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}
