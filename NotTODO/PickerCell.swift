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
        datePicker.isHidden = true
        datePicker.alpha = 0
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged(sender:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(datePickerValueDidChange(sender:)), for: .valueChanged)
        
        contentView.addSubview(label)
        contentView.addSubview(notificationSwitch)
        contentView.addSubview(bell)
        contentView.addSubview(datePicker)
        
        // Set up frames
        label.frame = CGRect(x: 15, y: 15, width: 200, height: 20)
        notificationSwitch.frame = CGRect(x: contentView.frame.width - 60, y: 10, width: 50, height: 30)
        bell.frame = CGRect(x: contentView.frame.width - 120, y: 10, width: 30, height: 30)
        datePicker.frame = CGRect(x: 15, y: 50, width: contentView.frame.width - 30, height: 150)
    }

    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
}
