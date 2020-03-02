//
//  MapTaggerLocationViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 07/05/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import SDWebImage
import CoreLocation
import MapKit
import CoreML
import ANLoader
import  EFInternetIndicator
class MapTaggerLocationViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,InternetStatusIndicable {
   
     var internetConnectionIndicator:InternetViewIndicator?
 
    @IBOutlet var outletMapView: GMSMapView!
    var lat : Double = 0.0
    var long : Double = 0.0
    var charactorURL : String = ""
    var needTitle = ""
    var taggerID = ""
    
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
  self.navigationController?.navigationBar.topItem?.title = " "
        // Do any additional setup after loading the view.
        let camera = GMSCameraPosition.camera(withLatitude:lat,
                                              longitude: long,
                                              zoom: 45,
                                              bearing: 0,
                                              viewingAngle: 0)
        outletMapView.camera = camera
        outletMapView.animate(toViewingAngle: 45)

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.showMarker(position: camera.target, title: needTitle, taggerID: taggerID, imageTag: charactorURL)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Map"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            ANLoader.hide()
        }
    }
    
    //Get current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        var currentLocation = locations.last! as CLLocation
        
        currentLocation = locManager.location!
        currentLatLong = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    //load marker on map
    func showMarker(position: CLLocationCoordinate2D, title: String, taggerID: String, imageTag: String){
        
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        
        if imageTag.isEqual("") {
            
        } else {
            
            let url1 = URL(string: imageTag)!
            let data = try? Data(contentsOf: url1)
            let image = self.imageByMergingImages(topImage:UIImage(data: data!)!, bottomImage: UIImage(named: "marker")!)
            marker.icon = image
        }
        marker.map = outletMapView
    }
    
    //marge two image
    func imageByMergingImages(topImage: UIImage, bottomImage: UIImage, scaleForTop: CGFloat = 1.0) -> UIImage {
        
        let size = bottomImage.size
        let container = CGRect(x: 0, y: 0, width: 40, height: 45)
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        UIGraphicsGetCurrentContext()!.interpolationQuality = .high
        bottomImage.draw(in: container)
        
        let topWidth = size.width / scaleForTop
        let topHeight = size.height / scaleForTop
        let topX = (size.width / 2.0) - (topWidth / 2.0)
        let topY = (size.height / 2.0) - (topHeight / 2.0)
        
        topImage.draw(in: CGRect(x: topX, y: topY, width: topWidth, height: topHeight-5), blendMode: .normal, alpha: 1.0)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    //If Google map app is install open it other wise Safari map
    @IBAction func directionAction(_ sender: Any) {
    
        let latitude: CLLocationDegrees = lat
        let longitude: CLLocationDegrees = long
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)){
            
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")! as URL)
            
        } else {
            
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.openURL(urlDestination)
            }
        }
    }
    
    // Dummay 
    @IBAction func openAction(_ sender: Any) {
    
        let latitude: CLLocationDegrees = lat
        let longitude: CLLocationDegrees = long
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)){
            
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")! as URL)
            
        } else {

            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.openURL(urlDestination)
            }
        }
    }
}
