//
//  SendBirdViewController.swift
//  GiftADeed
//
//  Created by Darshan on 4/30/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import Localize_Swift
import EFInternetIndicator
class SendBirdViewController: UIViewController,InternetStatusIndicable {
var userId = ""
     var internetConnectionIndicator:InternetViewIndicator?
    var name = ""
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        name = UserDefaults.standard.value(forKey: "Fname") as! String
         defaults.set("TRUE", forKey: "loginFlag")
        connect()
        // Do any additional setup after loading the view.
    }
    
    func connect() {
        let trimmedUserId: String = (userId.trimmingCharacters(in: NSCharacterSet.whitespaces))
        let trimmedNickname: String = (name.trimmingCharacters(in: NSCharacterSet.whitespaces))
        
        guard trimmedUserId.count > 0 && trimmedNickname.count > 0 else {
            return
        }
        ConnectionManager.login(userId: trimmedUserId, nickname: trimmedNickname) { (user, error) in
            DispatchQueue.main.async {
              
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
