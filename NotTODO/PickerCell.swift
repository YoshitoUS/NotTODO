import UIKit

class PickerCell: UITableViewCell {
    @IBOutlet weak var bellImageView: UIImageView!
    @IBOutlet weak var datePicker1: UIDatePicker!
    @IBOutlet weak var datePicker2: UIDatePicker!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!

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
        datePicker1.isHidden = true
        datePicker1.isUserInteractionEnabled = true
        datePicker1.addTarget(self, action: #selector(datePicker1Changed), for: .valueChanged)

        // datePicker2の設定
        datePicker2.preferredDatePickerStyle = .wheels
        datePicker2.datePickerMode = .time
        datePicker2.isHidden = true
        datePicker2.isUserInteractionEnabled = true

        // notificationSwitchの設定
        notificationSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    @objc private func switchChanged() {
        let isOn = notificationSwitch.isOn
        datePicker1.isHidden = !isOn
        datePicker2.isHidden = !isOn
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
