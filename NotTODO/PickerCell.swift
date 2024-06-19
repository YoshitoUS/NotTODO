import UIKit

class PickerCell: UITableViewCell {
    let bellImageView = UIImageView()
    let datePicker1 = UIDatePicker()
    let datePicker2 = UIDatePicker()
    let notificationSwitch = UISwitch()
    let label = UILabel()

    var onNotificationSwitchChanged: ((Bool, Date, Date) -> Void)?

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

        datePicker1.preferredDatePickerStyle = .inline
        datePicker1.datePickerMode = .date
        datePicker1.translatesAutoresizingMaskIntoConstraints = false
        datePicker1.isHidden = true // 初期状態で非表示
        datePicker1.isUserInteractionEnabled = true // ユーザーインタラクションを有効化
        datePicker1.addTarget(self, action: #selector(datePicker1Changed), for: .valueChanged)
        contentView.addSubview(datePicker1)

        datePicker2.preferredDatePickerStyle = .wheels
        datePicker2.datePickerMode = .time
        datePicker2.translatesAutoresizingMaskIntoConstraints = false
        datePicker2.isHidden = true // 初期状態で非表示
        datePicker2.isUserInteractionEnabled = true // ユーザーインタラクションを有効化
        contentView.addSubview(datePicker2)

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

            // Date picker 1 constraints
            datePicker1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker1.topAnchor.constraint(equalTo: bellImageView.bottomAnchor, constant: 16),
            datePicker1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Date picker 2 constraints
            datePicker2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker2.topAnchor.constraint(equalTo: datePicker1.bottomAnchor, constant: 16),
            datePicker2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    @objc private func switchChanged() {
        let isOn = notificationSwitch.isOn
        datePicker1.isHidden = !isOn
        datePicker2.isHidden = !isOn
        onNotificationSwitchChanged?(isOn, datePicker1.date, datePicker2.date)

        // レイアウトを更新してdatePickerの表示を切り替える
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @objc private func datePicker1Changed() {
        print("Date selected: \(datePicker1.date)")
    }
}
