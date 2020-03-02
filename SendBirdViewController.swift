//
//  SendBirdViewController.swift
//  GiftADeed
//
//  Created by Darshan on 4/30/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import SendBirdSDK

class SendBirdViewController: UIViewController {
var userId = ""
    var fName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        fName = UserDefaults.standard.value(forKey: "Fname")  as! String
        // Do any additional setup after loading the view.
    }
    
    func connect() {
        let trimmedUserId: String = (userId.trimmingCharacters(in: NSCharacterSet.whitespaces))
        let trimmedNickname: String = (fName.trimmingCharacters(in: NSCharacterSet.whitespaces))
        
        guard trimmedUserId.count > 0 && trimmedNickname.count > 0 else {
            return
        }
        
//        self.userIdTextField.isEnabled = false
//        self.nicknameTextField.isEnabled = false
        
      //  self.indicatorView.startAnimating()
        
        ConnectionManager.login(userId: trimmedUserId, nickname: trimmedNickname) { (user, error) in
            DispatchQueue.main.async {
//                self.userIdTextField.isEnabled = true
//                self.nicknameTextField.isEnabled = true
//
//                self.indicatorView.stopAnimating()
            }
            
            guard error == nil else {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                let vc = OpenChannelListViewController(nibName: "OpenChannelListViewController", bundle: Bundle.main)
                self.present(vc, animated: false) {
                    vc.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
                }
            }
        }
    }


}
