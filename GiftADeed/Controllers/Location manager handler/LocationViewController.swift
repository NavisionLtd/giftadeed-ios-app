//
//  NotificationTempViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 04/07/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//


import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var outletLocationTxt: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.startUpdatingLocation()
  }
  
  private lazy var locationManager: CLLocationManager = {
    
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    manager.distanceFilter = 1.0
    manager.delegate = self
    manager.requestAlwaysAuthorization()
    
    return manager
  }()
  
  // MARK: - CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let mostRecentLocation = locations.last else {
      return
    }
    
    if UIApplication.shared.applicationState == .active {
      
        print("App is foreground. New location is %@", mostRecentLocation)
        outletLocationTxt.text = String(format:"Foreground: %@",mostRecentLocation)
    } else {
        
        outletLocationTxt.text = String(format:"Background: %@",mostRecentLocation)
        print("App is backgrounded. New location is %@", mostRecentLocation)
    }
  }
}


