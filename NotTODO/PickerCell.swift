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
        if isOn {
            UIView.animate(withDuration: 0.3) {
                self.datePicker.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.datePicker.alpha = 0.0
            }
        }
    }

    private func prepare() {
        datePicker.isHidden = true
        datePicker.alpha = 0.0
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged(sender:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(datePickerValueDidChange(sender:)), for: .valueChanged)
        
        contentView.addSubview(label)
        contentView.addSubview(notificationSwitch)
        contentView.addSubview(bell)
        contentView.addSubview(datePicker)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        notificationSwitch.translatesAutoresizingMaskIntoConstraints = false
        bell.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            notificationSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            notificationSwitch.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            
            bell.trailingAnchor.constraint(equalTo: notificationSwitch.leadingAnchor, constant: -10),
            bell.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            datePicker.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }

    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
}
