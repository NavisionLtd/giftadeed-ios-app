//
//  EmergencyViewController.swift
//  GiftADeed
//
//  Created by Darshan on 4/8/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ContactsUI
import Localize_Swift
import MMDrawController

extension EmergencyViewController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let phoneNumberCount = contact.phoneNumbers.count
        
        guard phoneNumberCount > 0 else {
            dismiss(animated: true)
            //show pop up: "Selected contact does not have a number"
             self.view.makeToast("Selected contact does not have a number")
            return
        }
        
        if phoneNumberCount == 1 {
            setNumberFromContact(contactNumber: contact.phoneNumbers[0].value.stringValue, contactName: contact.givenName)
          
        } else {
            let alertController = UIAlertController(title: "Select one of the numbers", message: nil, preferredStyle: .alert)
            
            for i in 0...phoneNumberCount-1 {
                let phoneAction = UIAlertAction(title: contact.phoneNumbers[i].value.stringValue, style: .default, handler: {
                    alert -> Void in
                    self.setNumberFromContact(contactNumber: contact.phoneNumbers[i].value.stringValue, contactName: contact.givenName)
                })
                alertController.addAction(phoneAction)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: {
                alert -> Void in
                
            })
            alertController.addAction(cancelAction)
           
            dismiss(animated: true)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func setNumberFromContact(contactNumber: String,contactName: String) {
        
        //UPDATE YOUR NUMBER SELECTION LOGIC AND PERFORM ACTION WITH THE SELECTED NUMBER
        
        var contactNumber = contactNumber.replacingOccurrences(of: "-", with: "")
        contactNumber = contactNumber.replacingOccurrences(of: "(", with: "")
        contactNumber = contactNumber.replacingOccurrences(of: ")", with: "")
      //  contactNumber = contactNumber.removeWhitespacesInBetween()
        guard contactNumber.count >= 10 else {
            dismiss(animated: true) {
            //    self.popUpMessageError(value: 10, message: "Selected contact does not have a valid number")
                self.view.makeToast("Selected contact does not have a valid number")
            }
            return
        }
        if(self.flag == 1){
          firstEmergencyContact.placeholder = contactName
            firstEmergencyContact.text = String(contactNumber.suffix(10))}
        else if(self.flag == 2){
            secondEmergencyContact.placeholder = contactName
            secondEmergencyContact.text = String(contactNumber.suffix(10))
        }
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
    }
}
class EmergencyViewController: UIViewController,UITextFieldDelegate {
     var flag : Int = 0
    var plistHelepr = PlistManagment()
    // Define identifier
    let notificationsuccessName = Notification.Name("success")
    let notificationfailName = Notification.Name("fail")
    private let contactPicker = CNContactPickerViewController()
    @IBOutlet weak var secondEmergencyContact: UITextField!
    @IBOutlet weak var firstEmergencyContact: UITextField!
    @IBOutlet weak var emergencyLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    var back = ""
    @objc func setText(){
        firstEmergencyContact.placeholder = "Family member or Friend".localized()
        secondEmergencyContact.placeholder = "Family member or Friend".localized()
        emergencyLabel.text = "Contacts to send alert message in emergency situation".localized()
        self.saveBtn.setTitle("Submit".localized(using: "Localizable"), for: UIControlState.normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if(back == "BackPress"){
            self.menuBtn.image = UIImage (named: "Back")
        }
        else{
            self.menuBtn.image = UIImage (named: "menu")
        }
         self.navigationItem.title = "Emergency Contacts".localized()
        firstEmergencyContact.delegate = self
        secondEmergencyContact.delegate = self
        // Do any additional setup after loading the view.
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(EmergencyViewController.showSuccessToast), name: notificationsuccessName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EmergencyViewController.showFailToast), name: notificationfailName, object: nil)
        firstEmergencyContact.setBottomBorder()
        secondEmergencyContact.setBottomBorder()
        print(plistHelepr.readPlist(namePlist: "Options", key: "firstcontact") as? String)
        let first = plistHelepr.readPlist(namePlist: "Options", key: "firstcontact") as? String
        let second = plistHelepr.readPlist(namePlist: "Options", key: "secondcontact") as? String
        print(firstEmergencyContact.text)
        if(first == "0" && firstEmergencyContact.text == ""){
             firstEmergencyContact.text = ""
             firstEmergencyContact.placeholder = "Family member or Friend"
             setText()
        }
        else{
//            if let text = firstEmergencyContact.text, !text.isEmpty
//            {
//
//            }
            firstEmergencyContact.text = plistHelepr.readPlist(namePlist: "Options", key: "firstcontact") as? String
           
            firstEmergencyContact.placeholder = plistHelepr.readPlist(namePlist: "Options", key: "firstName") as? String
             print(firstEmergencyContact.placeholder)
              print(firstEmergencyContact.placeholder)
        }
        
        if(second == "0" && firstEmergencyContact.text == ""){
             secondEmergencyContact.text =  ""
             secondEmergencyContact.placeholder = "Family member or Friend"
             setText()
        }
        else{
              secondEmergencyContact.text = plistHelepr.readPlist(namePlist: "Options", key: "secondcontact") as? String
        secondEmergencyContact.placeholder = plistHelepr.readPlist(namePlist: "Options", key: "secondName") as? String
        }
       
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        print(textField)
      firstEmergencyContact.placeholder = "Family member or Friend"
         secondEmergencyContact.placeholder = "Family member or Friend"
        return allowedCharacters.isSuperset(of: characterSet)
    }
    @objc func showSuccessToast(){
        self.view.hideAllToasts()
       self.view.makeToast("Contact's has been saved successfully")
        NotificationCenter.default.removeObserver(notificationsuccessName)
        
     
         }
    @objc func showFailToast(){
        self.view.makeToast("Error during save contact's")
          NotificationCenter.default.removeObserver(notificationfailName)
    }
    @IBAction func firstContactBtnPress(_ sender: UIButton) {
         self.view.hideAllToasts()
        contactPicker.delegate = self
        self.flag = 1
        self.present(contactPicker, animated: true, completion: nil)
    }
    @IBAction func secondContactBtnPress(_ sender: UIButton) {
         self.view.hideAllToasts()
        contactPicker.delegate = self
         self.flag = 2
        self.present(contactPicker, animated: true, completion: nil)
    }
    @IBAction func saveContactsBtnPress(_ sender: UIButton) {
        plistHelepr.writePlist(namePlist: "Options", key: "firstcontact", data: firstEmergencyContact.text as AnyObject)
        plistHelepr.writePlist(namePlist: "Options", key: "secondcontact", data: secondEmergencyContact.text as AnyObject)
        
        plistHelepr.writePlist(namePlist: "Options", key: "firstName", data: firstEmergencyContact.placeholder as AnyObject)
        plistHelepr.writePlist(namePlist: "Options", key: "secondName", data: secondEmergencyContact.placeholder as AnyObject)
        
        print(firstEmergencyContact.text)
         print(firstEmergencyContact.text)
        if(back == "BackPress"){
            self.navigationController?.popViewController(animated: true)
        }else{
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
    @IBAction func menuBtnPress(_ sender: UIBarButtonItem) {
        if(back == "BackPress"){
            self.navigationController?.popViewController(animated: true)
            
        }else{
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
//        UIApplication.shared.keyWindow?.rootViewController = viewController
            if let drawer = self.drawer() ,
                let manager = drawer.getManager(direction: .left){
                let value = !manager.isShow
                drawer.isShowMask = true
                drawer.showLeftSlider(isShow: value)
            }
        }
    }

}
