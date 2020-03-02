//
//  CustomViewController.swift
//  GiftADeed
//
//  Created by KTS  on 15/06/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit

class CustomViewController: UITabBarController {

@IBOutlet weak var tabbarView: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
       self.tabBarController?.tabBar.items![0].title = "RUSHABH"
        // Do any additional setup after loading the view.
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
