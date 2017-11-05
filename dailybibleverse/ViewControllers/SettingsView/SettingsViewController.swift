//
//  SettingsViewController.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 11/1/17.
//  Copyright © 2017 Agustin Bivachi. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : UIViewController {

    @IBOutlet weak var timePickerView: UIView!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var hasReminderSwitch: UISwitch!

    @IBOutlet weak var timePickerViewBottomConstraint: NSLayoutConstraint!

    private let localStorage = LocalStorage.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        hasReminderSwitch.isOn = localStorage.getHasReminder()
    }

    @IBAction func changeBibleVersion(_ sender: UIButton) {

    }

    @IBAction func enableTimeReminder(_ sender: UISwitch) {
        localStorage.saveHasReminder(sender.isOn)
    }

    @IBAction func openTimePicker(_ sender: UISwitch) {
        showTimePickerView(true)
    }

    @IBAction func setTime(_ sender: UIButton) {
        showTimePickerView(false)
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func showTimePickerView(_ show: Bool) {
        timePickerViewBottomConstraint.constant = show ? 0 : -timePickerView.frame.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
}
