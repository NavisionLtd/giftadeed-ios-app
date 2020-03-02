//
//  SuccessPopupViewController.swift
//  GiftADeed
//
//  Created by KTS  on 10/12/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import SwiftGifOrigin
class SuccessPopupViewController: UIViewController {
    var wonPoints = ""
    var needName = ""
    var totalWonPoints = ""
    var viewFrom = ""
    @IBOutlet weak var successImgView: UIImageView!
    @IBOutlet weak var wonPointsLbl: UILabel!
    @IBOutlet weak var needNameLbl: UILabel!
    @IBOutlet weak var totalPointsWonLbl: UILabel!
    
    @IBOutlet weak var pointsByLbl: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popUpView.layer.cornerRadius = 10
        self.shareBtn.layer.cornerRadius = 10
 self.navigationController?.setNavigationBarHidden(true, animated: true)
        if(self.viewFrom == "tagadeed"){
            self.successImgView.loadGif(name: "newthumb")
            self.needNameLbl.halfTextColorChange(fullText: "\(needName) need", changeText: "\(needName)")
            self.wonPointsLbl.halfTextColorChange(fullText: "\(wonPoints) ", changeText: "\(wonPoints)")
            self.totalPointsWonLbl.halfTextColorChange(fullText: "Your total points are \(totalWonPoints)", changeText: "\(totalWonPoints)")
            self.pointsByLbl.text = "points by tagging"
        }
        else{
            self.successImgView.loadGif(name: "smiley-face")
            self.needNameLbl.halfTextColorChange(fullText: "\(needName) need", changeText: "\(needName)")
            self.wonPointsLbl.halfTextColorChange(fullText: "\(wonPoints) ", changeText: "\(wonPoints)")
            self.totalPointsWonLbl.halfTextColorChange(fullText: "Your total points are \(totalWonPoints)", changeText: "\(totalWonPoints)")
            self.pointsByLbl.text = "points by fulfilling"
        }
        
     
        // Do any additional setup after loading the view.
    }
    @IBAction func tellYourFriendBtnPress(_ sender: UIButton) {
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
    }
    
    @IBAction func closePopUpBtnPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
            UIApplication.shared.keyWindow?.rootViewController = viewController
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

}
