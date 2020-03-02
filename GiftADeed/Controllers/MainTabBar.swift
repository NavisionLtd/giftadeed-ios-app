//
//  MainTabBarController.swift
//  TabBarSolution
//
//  Created by Dejan Skledar on 03/07/2017.
//  Copyright © 2017 FERI. All rights reserved.
//

import UIKit
import EFInternetIndicator
class MainTabBar: UITabBar {
 
    private var middleButton = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupMiddleButton()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let from = point
        let to = middleButton.center

        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
    }

    func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: 40, height: 40)
        middleButton.backgroundColor = .gray
       middleButton.setImage(#imageLiteral(resourceName: "plus"), for: UIControlState.normal)
        middleButton.layer.cornerRadius = 20
        middleButton.layer.masksToBounds = true
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        middleButton.addTarget(self, action: #selector(test), for: .touchUpInside)
     //   addSubview(middleButton)
    }

    @objc func test() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tagADeed") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = viewController
        print("my name is jeff")
    }
}
