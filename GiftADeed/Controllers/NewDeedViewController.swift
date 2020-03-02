//
//  NewDeedViewController.swift
//  GiftADeed
//
//  Created by Darshan on 11/14/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class NewDeedViewController: UIViewController {

    @IBOutlet weak var tagViewScroller: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    @IBAction func menuBarAction(_ sender: Any) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}
