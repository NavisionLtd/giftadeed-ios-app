  //
//  ViewController.swift
//  MMDrawController
//
//  Created by millmanyang@gmail.com on 03/30/2017.
//  Copyright (c) 2017 millmanyang@gmail.com. All rights reserved.
//

import UIKit
import MMDrawController
  import ListPlaceholder
  class ViewController: MMDrawerViewController {
  
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Init by storyboard identifier
        super.setMainWith(identifier: "Home")
          if Device.IS_IPHONE {
        super.setLeftWith(identifier: "Member", mode: .frontWidthRate(r: 0.8))
        }
          else if Device.IS_IPAD  {
              super.setLeftWith(identifier: "Member", mode: .frontWidthRate(r: 0.4))
        }
        //Init by Code
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let right = story.instantiateViewController(withIdentifier: "SliderRight")
      //  super.set(right: right, mode: .rearWidth(w: 100))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

