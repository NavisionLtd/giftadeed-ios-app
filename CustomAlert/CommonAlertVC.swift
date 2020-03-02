//
//  CommonAlertVC.swift
//  WeMinder
//
//  Created by Krishna on 21/05/19.
//  Copyright © 2019 Krishna All rights reserved.
//

import UIKit
import Localize_Swift

class CommonAlertVC: UIViewController {

    @IBOutlet weak var fantastcLbl: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var earnedPointsLbl: UILabel!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonOkay: UIButton!
    
    @IBOutlet weak var imageViewItem: UIImageView!
    
    @IBOutlet weak var heightViewContainer: NSLayoutConstraint!
    
    var message: String = ""
    var descriptionMessage: String = ""
    var imageItem: UIImage?
    var totalEarnedPoints: String = ""
    var actionDic: [String: () -> Void]?
    var isContactNumberHidden: Bool = true
    
    @IBOutlet weak var wonLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
self.buttonOkay.setTitle("Tell Your Friends".localized(), for: .normal)
        self.wonLbl.text = "You've won".localized()
        self.fantastcLbl.text = "Fantastic !".localized()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewContainer.layer.cornerRadius = 20.0
        viewContainer.layer.masksToBounds = true
//        buttonOkay.addCornerRadiusWithShadow(color: .lightGray, borderColor: .clear, cornerRadius: 25)
//        buttonCancel.setCornerRadiusWith(radius: 25, borderWidth: 1.0, borderColor: #colorLiteral(red: 0.03529411765, green: 0.2274509804, blue: 0.9333333333, alpha: 1))
        
        self.labelMessage.text = message
        self.labelDescription.text = descriptionMessage
         self.earnedPointsLbl.text = totalEarnedPoints
        if imageItem == nil {
            imageViewItem.isHidden = true
        } else {
            imageViewItem.isHidden = false
            imageViewItem.image = imageItem!
        }
        
        if (descriptionMessage.count) > 0 && (imageItem != nil) {
            heightViewContainer.constant = 400
        } else if (descriptionMessage.count) > 0 && (imageItem == nil) {
            heightViewContainer.constant = 350
        }

        if actionDic == nil {
            buttonCancel.isHidden = true
        } else {
            var count = 0
            for (key, _) in actionDic! {
                if count > 1 {
                    return
                }
                let buttonTitle: String = key.uppercased()
                if buttonTitle == "OKAY" || buttonTitle == "OK" || buttonTitle == "YES" {
                    buttonOkay.setTitle(buttonTitle, for: .normal)
                } else {
                    buttonCancel.setTitle(buttonTitle, for: .normal)
                }
                count += 1
            }
        }       
    }

    // MARK: - IBAction Methods
    
    @IBAction func contactButtonAction(sender: UIButton) {
        if let url = URL(string: "tel://\(sender.titleLabel?.text ?? "")") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func cancelButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

        if actionDic != nil {
            var count = 0
            for (key, value) in actionDic! {
                let action: () -> Void = value
                if key == sender.titleLabel?.text?.uppercased() {
                    action()
                }
                count += 1
            }
        }
    }
    
    @IBAction func cancelBtnPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
           
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        if actionDic != nil {
            var count = 0
            for (key, value) in actionDic! {
                let action: () -> Void = value
                if key == sender.titleLabel?.text?.uppercased() {
                    action()
                }
                count += 1
            }
        }
    }
    @objc func share(sender:UIView){
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let textToShare = Constant.GAD_SHARE_TEXT
        
        if let myWebsite = URL(string: "http://tiny.cc/h4533y") {//Enter link to your app here
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "login_logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }    }
    @IBAction func okeyPress(_ sender: UIButton) {
      //self.dismiss(animated: true, completion: nil)
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let textToShare = Constant.GAD_SHARE_TEXT
        
        if let myWebsite = URL(string: "http://tiny.cc/h4533y") {//Enter link to your app here
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "login_logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
        if actionDic != nil {
            var count = 0
            for (key, value) in actionDic! {
                let action: () -> Void = value
                if key == sender.titleLabel?.text?.uppercased() {
                    action()
                }
                count += 1
            }
        }
    }
    @IBAction func okayButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

        if actionDic != nil {
            var count = 0
            for (key, value) in actionDic! {
                let action: () -> Void = value
                if key == sender.titleLabel?.text?.uppercased() {
                    action()
                }
                count += 1
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    static func showAlertWithTitle(_ title: String?, message : String?, actionDic : [String: (UIAlertAction) -> Void]) {
        var alertTitle : String = title!
        if title == nil {
            alertTitle = ""
        }
        let alert : UIAlertController = UIAlertController.init(title: alertTitle, message: message, preferredStyle: .alert)
        
        for (key, value) in actionDic {
            let buttonTitle : String = key
            let action: (UIAlertAction) -> Void = value
            alert.addAction(UIAlertAction.init(title: buttonTitle, style: .default, handler: action))
        }
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true, completion: nil)
        
    }
   
    
}
