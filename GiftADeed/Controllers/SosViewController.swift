//
//  SosViewController.swift
//  GiftADeed
//
//  Created by Darshan on 10/31/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import Lottie
import UIKit
import ContactsUI
import Contacts
import MessageUI
import ANLoader
import EFInternetIndicator
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: "AvenirNext-Medium", size: 12)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
extension String {
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
}
class SosViewController: UIViewController  , MFMessageComposeViewControllerDelegate,CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,InternetStatusIndicable{
     var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var imgContain: AnimationView!
    @IBOutlet var imgContainers: AnimationView!
    @IBOutlet weak var emergencyTitle: UILabel!
    var emergency_contact = ""
    var selectedIndex = ""
    @IBOutlet weak var alertImgView: UIImageView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ,
            let label = cell.viewWithTag(100) as? UILabel{
            label.text = titleArr[indexPath.row]
            cell.layoutMargins = UIEdgeInsets.zero
            
            let img = cell.viewWithTag(101) as? UIImageView
            img?.image = UIImage (named: imgArr[indexPath.row])
            
            if(self.selectedIndex == "Selected"){
                //cell.backgroundColor = UIColor.red
                
            }else{
                cell.backgroundColor = UIColor.clear
            }
             let btn = cell.viewWithTag(102) as? UIButton
            if(indexPath.row == 1){
                if(isPresent){
                    self.numberSetAlert.isHidden = true
                    btn?.isHidden = true
                }
                else{
                     btn?.isHidden = false
                    btn!.setTitle("Set".localized(using: "Localizable"), for: UIControlState.normal)
                    self.numberSetAlert.isHidden = false
                    btn?.addTarget(self, action: #selector(setNo), for: .touchUpInside)
                }
            }
            else{
                 btn?.isHidden = true
            }
        
            return cell
        }
        
        return UITableViewCell()
    }
    @objc func setNo(){
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "EmergencyViewController") as? EmergencyViewController
          mapViewControllerObj?.back = "BackPress"
        self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            print("Call police")
            callPoliceApi()
           self.selectedIndex = "Selected"
        }
        else if(indexPath.row == 1){
            alertContact()
            print("Alert send msg to your saved contact")
             self.selectedIndex = "Selected"
        }
        else{
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "sosimage") as! SosImageUploadViewController
            viewController.latitudeLongitude = addressLocation
                     viewController.latitude = latitude
                     viewController.longitude = longitude
            viewController.backPress = "From Login"
           self.navigationController?.pushViewController(viewController, animated: true)
             self.selectedIndex = "Selected"
              print("send images")
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55.0;//Choose your custom row height
    }
    func callPolice(){
        
        let phoneNumberString = fcontact.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        if let url = URL(string: "tel://\(self.emergency_contact)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    func alertContact(){
        if (MFMessageComposeViewController.canSendText())
        {
            let controller = MFMessageComposeViewController()
            let urlToShare = "comgooglemapsurl://maps.google.com/?q=\(addressLocation)"
            controller.body = "This number is added as emergency contact please help user , user is now at \(urlToShare)  location"
            //UIApplication.shared.openURL(URL(string:"https://www.google.com/maps/@42.585444,13.007813,6z")!)
            let firstContact = plistHelepr.readPlist(namePlist: "Options", key: "firstcontact") as? String
            let secondContact = plistHelepr.readPlist(namePlist: "Options", key: "secondcontact") as? String
            let first = firstContact!.trimmingCharacters(in: .whitespaces)
            let second = secondContact!.trimmingCharacters(in: .whitespaces)
            let recipientsArray = [first.stripped,second.stripped]
            controller.recipients = recipientsArray as? [String]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else
        {
            print("Error")
        }
    }
 
    @IBAction func dismissBtnPress(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    let titleArr = ["Call police control room".localized(),"Alert your emergency contact".localized(),"Share your location".localized()]
    let imgArr = ["call.png","comment-1","location"]
    @IBOutlet weak var sosTable: UITableView!
    @IBOutlet weak var emergencyThirdLbl: UILabel!
    @IBOutlet weak var emergencySecondLbl: UILabel!
    @IBOutlet weak var emergencyFirstLbl: UILabel!
    @IBOutlet weak var thirdNumber: UIButton!
    @IBOutlet weak var callSaveBtn: UIButton!
    @IBOutlet weak var secondNumber: UIButton!
    @IBOutlet weak var firstNumber: UIButton!
    @IBOutlet weak var numberSetAlert: UIButton!
    var isPresent : Bool = false
    let locationManager = CLLocationManager()
    var plistHelepr = PlistManagment()
    var addressLocation = ""
    var latitude : CLLocationDegrees = 0.0
    var longitude : CLLocationDegrees = 0.0
    var phone = ""
    var fcontact = "8888888888"
     var scontact = ""
    var back = ""
    var flag : Int = 0
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: Localized Text
    
    @objc func setText(){
        emergencyTitle.text = "USE IN CASE OF EMERGENCY".localized();
       numberSetAlert.setTitle("You haven't set  number for emergency contact.".localized(), for: UIControlState.normal)
      
    }
    
    @IBAction func backBtnPress(_ sender: Any) {
        back = UserDefaults.standard.string(forKey: "BackPress")!
        print(back)
        if(back == "login")
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "login")
            UIApplication.shared.keyWindow?.rootViewController = viewController
            //            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
//            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        else{
            DispatchQueue.main.async {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
    
        } }
    func playAnimation(){
//        imgContain.setAnimation(named: "techno_penguin")
//        imgContain.loopAnimation = true
//        imgContain.play()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        self.navigationItem.title = "SOS".localized()
        self.sosTable.separatorColor = UIColor.black
        self.sosTable.layoutMargins = UIEdgeInsets.zero
        self.sosTable.separatorInset = UIEdgeInsets.zero
        self.sosTable.tableFooterView = UIView()
        self.tabBarController?.tabBar.isHidden = true

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        latitude = locValue.latitude
        longitude = locValue.longitude
        addressLocation =  String(format:"%f,%f", locValue.latitude,locValue.longitude)
        print(addressLocation)
        
    }
    func callPoliceApi(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.country_emergency_number
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "geopoints=%@",addressLocation)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    //self.view.hideAllToasts()
                    //self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                   print(jsonObj!)
                DispatchQueue.main.async{
                let status = jsonObj?.value(forKey: "status") as! Int
                if(status == 1){
                    self.view.hideAllToasts()
                    let success_message = jsonObj?.value(forKey: "success_message") as! String
                    self.view.makeToast(success_message)
                    self.emergency_contact = jsonObj?.value(forKey: "emergency_contact_number") as! String
                    self.callPolice()
                }
                else if(status == 0){
                    // now check for 3 errror status
                    self.view.hideAllToasts()
                    let error_message = jsonObj?.value(forKey: "error_message") as! String
                    self.view.makeToast(error_message)
                }
                    else if(status == 2){
                    self.view.hideAllToasts()
                    // now check for 3 errror status
                    let error_message = jsonObj?.value(forKey: "error_message") as! String
                    self.view.makeToast(error_message)
                    }
                    else if(status == 3){
                    self.view.hideAllToasts()
                    // now check for 3 errror status
                    let error_message = jsonObj?.value(forKey: "error_message") as! String
                    self.view.makeToast(error_message)
                } else if(status == 4){
                    self.view.hideAllToasts()
                    // now check for 3 errror status
                    let error_message = jsonObj?.value(forKey: "error_message") as! String
                    self.view.makeToast(error_message)
                } else if(status == 5){
                    self.view.hideAllToasts()
                    // now check for 3 errror status
                    let error_message = jsonObj?.value(forKey: "error_message") as! String
                    self.view.makeToast(error_message)
                }
                else if(status == 6){
                    
                    self.view.hideAllToasts()
                    // now check for 3 errror status
                    let error_message = jsonObj?.value(forKey: "error_message") as! String
                    self.view.makeToast(error_message)
                }
       
                 }
            }
        }
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //check if numbers are present or not
        let firstContact = plistHelepr.readPlist(namePlist: "Options", key: "firstcontact") as? String
        let secondContact = plistHelepr.readPlist(namePlist: "Options", key: "secondcontact") as? String
        let first = firstContact!.trimmingCharacters(in: .whitespaces)
        let second = secondContact!.trimmingCharacters(in: .whitespaces)
        if(first.count > 1 && second.count > 1){
            //number present hide set btn
            isPresent = true
            self.sosTable.reloadData()
        self.numberSetAlert.isHidden = true
        }
        else{
            //show set btn
             self.numberSetAlert.isHidden = false
            isPresent = false
        }
setText()
        //  playAnimation()
        
        self.imgContain.play()
        self.imgContain.loopMode = .loop
    }

    @IBAction func addionalInfoBtnPress(_ sender: UIBarButtonItem) {
    }

}
