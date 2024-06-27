import UIKit

class PickerCell: UITableViewCell {
    @IBOutlet weak var bellImageView: UIImageView!
    @IBOutlet weak var datePicker1: UIDatePicker!
    @IBOutlet weak var datePicker2: UIDatePicker!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!

    let deadlineLabel = UILabel()
    let notificationTimeLabel = UILabel()

    var onNotificationSwitchChanged: ((Bool, Date, Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    private func setupViews() {
        // デバッグ用コード
        if datePicker1 == nil {
            print("datePicker1 is nil")
        } else {
            print("datePicker1 is connected")
        }

        if datePicker2 == nil {
            print("datePicker2 is nil")
        } else {
            print("datePicker2 is connected")
        }

        if notificationSwitch == nil {
            print("notificationSwitch is nil")
        } else {
            print("notificationSwitch is connected")
        }

        // datePicker1の設定
        datePicker1.preferredDatePickerStyle = .inline
        datePicker1.datePickerMode = .date
<<<<<<< HEAD
        datePicker1.isHidden = true
        datePicker1.isUserInteractionEnabled = true
        datePicker1.addTarget(self, action: #selector(datePicker1Changed), for: .valueChanged)
=======
        datePicker1.translatesAutoresizingMaskIntoConstraints = false
        datePicker1.isHidden = true // 初期状態で非表示
        contentView.addSubview(datePicker1)
>>>>>>> hoge

        // datePicker2の設定
        datePicker2.preferredDatePickerStyle = .wheels
        datePicker2.datePickerMode = .time
<<<<<<< HEAD
        datePicker2.isHidden = true
        datePicker2.isUserInteractionEnabled = true
=======
        datePicker2.translatesAutoresizingMaskIntoConstraints = false
        datePicker2.isHidden = true // 初期状態で非表示
        contentView.addSubview(datePicker2)
>>>>>>> hoge

        // notificationSwitchの設定
        notificationSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
<<<<<<< HEAD
    }

=======
        contentView.addSubview(notificationSwitch)

        label.text = "通知"
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        // 新しいラベルの設定
        deadlineLabel.text = "期限"
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deadlineLabel)

        notificationTimeLabel.text = "通知時間"
        notificationTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(notificationTimeLabel)
        
        // 初期状態で新しいラベルを非表示にする
        deadlineLabel.isHidden = true
        notificationTimeLabel.isHidden = true
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

            // Deadline label constraints
            deadlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deadlineLabel.topAnchor.constraint(equalTo: bellImageView.bottomAnchor, constant: 16),

            // Date picker 1 constraints
            datePicker1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker1.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor, constant: 8),
            datePicker1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker1.widthAnchor.constraint(greaterThanOrEqualToConstant: 280),

            // Notification time label constraints
            notificationTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            notificationTimeLabel.topAnchor.constraint(equalTo: datePicker1.bottomAnchor, constant: 8),

            // Date picker 2 constraints
            datePicker2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker2.topAnchor.constraint(equalTo: notificationTimeLabel.bottomAnchor, constant: 8),
            datePicker2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            datePicker2.widthAnchor.constraint(greaterThanOrEqualToConstant: 280)
        ])
    }

>>>>>>> hoge
    @objc private func switchChanged() {
        let isOn = notificationSwitch.isOn
        datePicker1.isHidden = !isOn
        datePicker2.isHidden = !isOn
        deadlineLabel.isHidden = !isOn
        notificationTimeLabel.isHidden = !isOn
        onNotificationSwitchChanged?(isOn, datePicker1.date, datePicker2.date)

        // デバッグログの追加
        print("Date Picker 1 is \(datePicker1.isHidden ? "hidden" : "visible"), user interaction enabled: \(datePicker1.isUserInteractionEnabled)")
        print("Date Picker 2 is \(datePicker2.isHidden ? "hidden" : "visible"), user interaction enabled: \(datePicker2.isUserInteractionEnabled)")

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @objc private func datePicker1Changed() {
        print("Date selected: \(datePicker1.date)")
    }
}
