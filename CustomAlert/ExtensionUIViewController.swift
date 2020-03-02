//
//  ExtensionUIViewController.swift
//
//
//  Created by Krishna on 21/05/19.
//  Copyright © 2019 Krishna All rights reserved.
//

import UIKit
import AlertTransition
extension UIViewController {

    func showCustomAlertWith(message: String, descMsg: String, totalEarnedMsg: String, itemimage: UIImage?, actions: [String: () -> Void]?) {
        let alertVC = CommonAlertVC.init(nibName: "CommonAlertVC", bundle: nil)
        alertVC.message = message
        alertVC.actionDic = actions
        alertVC.descriptionMessage = descMsg
        alertVC.imageItem = itemimage
        alertVC.totalEarnedPoints = totalEarnedMsg
        //Present
        //   alertVC.at.transition = StarWallTransition()
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }
}
