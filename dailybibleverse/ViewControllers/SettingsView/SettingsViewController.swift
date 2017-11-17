//
//  SettingsViewController.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 11/1/17.
//  Copyright © 2017 Agustin Bivachi. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class SettingsViewController : UIViewController {

    @IBOutlet weak var timePickerView: UIView!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var hasReminderSwitch: UISwitch!
    @IBOutlet weak var kjvTranslation: UIImageView!
    @IBOutlet weak var nivTranslation: UIImageView!
    
    @IBOutlet weak var timePickerViewBottomConstraint: NSLayoutConstraint!

    private let localStorage = LocalStorage.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
        let date = dateFormatter.date(from: "08:00")
        
        pickerView.date = date!
    
        hasReminderSwitch.isOn = localStorage.getHasReminder()
        if (localStorage.getBibleVersion() == 1) {
            kjvTranslation.image = UIImage(named : "ic_radio_button_checked")
            nivTranslation.image = UIImage(named : "ic_radio_button_unchecked")
        } else {
            kjvTranslation.image = UIImage(named : "ic_radio_button_unchecked")
            nivTranslation.image = UIImage(named : "ic_radio_button_checked")
        }
    }

    @IBAction func changeBibleVersion(_ sender: UIButton) {

    }

    @IBAction func enableTimeReminder(_ sender: UISwitch) {
        localStorage.saveHasReminder(sender.isOn)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { (allawed, error) in
            if(allawed) {
                if !sender.isOn {
                    
                }
            } else {
                if sender.isOn {
                    if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(appSettings,options: [:], completionHandler:nil)
                    }
                }
                
            }
        }
    }

    @IBAction func openTimePicker(_ sender: UISwitch) {
        showTimePickerView(true)
    }

    @IBAction func setTime(_ sender: UIButton) {

        //NO SE si funciona esto poruqe deberia reemplazar la que esta por default pero no encontre nada para haerlo
        pickerView.datePickerMode = UIDatePickerMode.date
        let selectedDate=pickerView.timeZone
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Bible Verse"
        content.body = "Your Daily Bible Verse is Ready"
        
        let componentsFromDate = Calendar.current.dateComponents(in: selectedDate!, from: Date())
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: componentsFromDate, repeats: true)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        showTimePickerView(false)
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func kjvTranslationButton(_ sender: UIButton) {
        localStorage.saveBibleVersion(1)
        kjvTranslation.image = UIImage(named : "ic_radio_button_checked")
        nivTranslation.image = UIImage(named : "ic_radio_button_unchecked")
        localStorage.setDidTranslationChange(true)
    }
    
    @IBAction func nivTranslationButton(_ sender: UIButton) {
        localStorage.saveBibleVersion(2)
        kjvTranslation.image = UIImage(named : "ic_radio_button_unchecked")
        nivTranslation.image = UIImage(named : "ic_radio_button_checked")
        localStorage.setDidTranslationChange(true)
    }
    
    func showTimePickerView(_ show: Bool) {
        timePickerViewBottomConstraint.constant = show ? 0 : -timePickerView.frame.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
}
