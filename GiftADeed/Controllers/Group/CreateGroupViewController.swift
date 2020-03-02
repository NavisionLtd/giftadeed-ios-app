//
//  CreateGroupViewController.swift
//  GiftADeed
//
//  Created by Darshan on 2/16/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
// Ref : 2.1

import UIKit
import ANLoader
import SDWebImage
import SendBirdSDK
import Localize_Swift
import MMDrawController

extension UIButton{
    func setBorder(){
        self.backgroundColor = .clear
        self.layer.cornerRadius = 2
        self.layer.borderWidth = 0.1
        self.layer.borderColor = UIColor.black.cgColor
        
    }
}
extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
extension String {
    
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    var length: Int {
        return self.characters.count
    }
}
struct EditGroup {
    let grp_name : String
    let creator_name : String
    let creator_id : String
    let create_date : String
    let admin_ids : String
    let description : String
    let group_logo : String
}
class CreateGroupViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var groupDescriptionTxtFeild: FloatLabelTextField!
    @IBOutlet weak var groupNameTxtFeild: FloatLabelTextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var groupIconView: UIImageView!
    @IBOutlet weak var browsePictureBtn: UIButton!
    @IBOutlet weak var takePictureBtn: UIButton!
    @IBOutlet weak var groupCoverImg: UIImageView!
    let imagePicker = UIImagePickerController()
    var imageBase64 = ""
    var userId = ""
    var group_id = ""
    var group_name = ""
    var controller = ""
    let defaults = UserDefaults.standard
    //sendbird
       var channels: [SBDGroupChannel] = []
    fileprivate var myGroupChannelListQuery: SBDGroupChannelListQuery?
    
    var editgroupListArray = [EditGroup]()
    func setText(){
        self.saveBtn.setTitle("Save".localized(), for: .normal)
         self.browsePictureBtn.setTitle("Browse".localized(), for: .normal)
         self.takePictureBtn.setTitle("Take Picture".localized(), for: .normal)
        self.groupNameTxtFeild.placeholder = "Group Name".localized()
        self.groupDescriptionTxtFeild.placeholder = "Group Description".localized()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if(group_id == "")
        {
            self.navigationItem.title = "Create Group".localized()
            
            
        }else{
           // getGroupInfoApiCall()
            
            self.navigationItem.title = "Edit Group".localized()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       setText()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
         self.saveBtn.layer.cornerRadius = 5
        self.navigationController?.navigationBar.topItem?.title = " "
        if(group_id == "")
        {
            self.navigationItem.title = "Create Group".localized()
            
        
        }else{
            getGroupInfoApiCall()
          
            self.navigationItem.title = "Edit Group".localized()
        }
        
         groupIconView.isHidden = false
        //get userid to create group and send data to API
         userId = defaults.value(forKey: "User_ID") as! String
         var  name = UserDefaults.standard.value(forKey: "Fname") as! String
        //Hide nav back button title self.navigationController?.navigationBar.topItem?.title = ""
        //set nav bar title heading
      //  self.navigationItem.title = "Create Group"
        //add border to center group icon
        groupIconView.layer.borderWidth = 0.5
        groupIconView.layer.borderColor = UIColor.white.cgColor
        //add border to groupcover
        groupCoverImg.layer.borderWidth = 0.5
        groupCoverImg.layer.borderColor = UIColor.black.cgColor
        //add border to takepicture button
        takePictureBtn.layer.cornerRadius = 5
        takePictureBtn.layer.borderWidth = 0.5
        takePictureBtn.layer.borderColor = UIColor.black.cgColor
        //add border to browse button
        browsePictureBtn.layer.cornerRadius = 5
        browsePictureBtn.layer.borderWidth = 0.5
        browsePictureBtn.layer.borderColor = UIColor.black.cgColor
        //Set bottom line to textfeild
        groupNameTxtFeild.setBottomBorder()
        groupDescriptionTxtFeild.setBottomBorder()
        //set textfeild delegate
        groupNameTxtFeild.delegate = self
        groupDescriptionTxtFeild.delegate = self
        //imagepicker delegate to upload picture
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        //sendbird
        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery?.limit = 10
        SBDMain.connect(withUserId: self.userId, completionHandler: { (user, error) in
            if error == nil {
                SBDMain.updateCurrentUserInfo(withNickname: name, profileUrl: nil, completionHandler: { (error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true, completion: nil)
                        })
                        return
                    }
                                            UserDefaults.standard.set(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
                                            UserDefaults.standard.set(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_nickname")
                })
            }
            else {
                let alert = UIAlertController(title: "Error", message: String(format: "%lld-%@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(closeAction)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
        })
        let query = SBDGroupChannel.createMyGroupChannelListQuery()
        query?.includeEmptyChannel = false
        query?.loadNextPage(completionHandler: { (channels, error) in
            guard error == nil else {   // Error.
                return
            }
            print(channels as Any)
            print(channels?.count as Any)
            //  self.chanelNameArray.add(channels as Any)
            // ...
        })
    }
    //validation of textfeilds
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == groupNameTxtFeild){
            if string.characters.count == 0 {
                return true
            }
            let currentText = groupNameTxtFeild.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let newString = (currentText as NSString).replacingCharacters(in: range, with: string) as NSString
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_.@0123456789") &&
                newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 && newString.length <= 30
        }
        else if(textField == groupDescriptionTxtFeild){
            if string.characters.count == 0 {
                return true
            }
            let currentText = groupDescriptionTxtFeild.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let newString = (currentText as NSString).replacingCharacters(in: range, with: string) as NSString
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_.#$&%^!@0123456789 ") &&
                newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 && newString.length <= 500
        }
            
        else{
            return true
        }
    }
    //validation end
    @IBAction func saveBtnPress(_ sender: UIButton) {
        if((groupNameTxtFeild.text?.isEmpty)!){
            self.view.makeToast("Please fill all required feilds",position:.center)
            self.groupNameTxtFeild.becomeFirstResponder()
        }
        else{
            self.view.hideAllToasts()
            //Api function call
              if(group_id == "")
              {
                 createGroupApiCall()
            }
              else{
                 self.editGroupApiCall()
          
            }
           
        }
    }
    
    @IBAction func galleryBtnPress(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func cameraBtnPress(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        groupIconView.isHidden = true
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.groupCoverImg.image = editedImage;
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.groupCoverImg.image = originalImage;
        }
        picker.dismiss(animated: true)
       // imageFlag = true
        self.imageBase64 = GlobalClass.sharedInstance.encodeToBase64String(image:self.groupCoverImg.image!)!
    }
    //Fetch groupinfo for edit
    func getGroupInfoApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.groupInfo
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@&group_id=%@",userId,group_id)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                print(jsonObj as Any)
                if(jsonObj?.count == 0){
                    self.view.makeToast("Something went wrong! Please try again.".localized())
                }else{
                    for values in jsonObj!{
                        let admin_ids = (values as AnyObject).value(forKey: "admin_ids") as! String
                        let create_date = (values as AnyObject).value(forKey: "create_date") as! String
                        let creator_id = (values as AnyObject).value(forKey: "creator_id") as! String
                        let creator_name = (values as AnyObject).value(forKey: "creator_name") as! String
                        let description = (values as AnyObject).value(forKey: "description") as! String
                        let group_logo = (values as AnyObject).value(forKey: "group_logo") as! String
                        let grp_name = (values as AnyObject).value(forKey: "grp_name") as! String
                        let editGroup = EditGroup(grp_name: grp_name, creator_name: creator_name, creator_id: creator_id, create_date: create_date, admin_ids: admin_ids, description: description, group_logo: group_logo)
                        self.editgroupListArray.append(editGroup)
                    }
                    DispatchQueue.main.async{
                        
                        for values in self.editgroupListArray{
                            self.groupNameTxtFeild.text = values.grp_name
                            self.groupDescriptionTxtFeild.text = values.description
                            let img = values.group_logo
                            let imgUrl = ("\(Constant.BASE_URL)\(img)")
                            if img == ""{
                                  self.groupIconView.isHidden = false
                                self.groupIconView.image = UIImage(named: "ic_launcher-1")
                            }
                            else{
                                self.groupIconView.isHidden = true
                                self.groupCoverImg.sd_setImage(with: URL(string: imgUrl), placeholderImage:nil)
                            }
                        }
                    }
                }
              
                
            }
        }
        
        task.resume()
    }
    //to edit existing group
    func editGroupApiCall(){
        
        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.".localized())
            }
        }
        else{
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.editGroup
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "img=%@&name=%@&user_id=%@&desc=%@&group_id=%@",self.imageBase64.addingPercentEncoding(withAllowedCharacters: charset as CharacterSet)!,groupNameTxtFeild.text!,userId,groupDescriptionTxtFeild.text!,group_id)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj as Any)
                let status = jsonObj?.value(forKey: "status") as! Int
                if(status == 1){
                    DispatchQueue.main.async {
                        //Sendbird edit channel
                        var channel: SBDGroupChannel
                        //   self.channels.removeAll()
                        for item in self.channels {
                            channel = item as SBDGroupChannel
                            self.channels.append(channel)
                            print(self.channels)
                            print(channel.name)
                            print(channel.channelUrl)
                            let fullName   = "\(self.group_name) - GRP\(self.group_id)"
                            print("\(channel.name)\(fullName)")
                            if(channel.name == fullName){
                                print("chanel is present")
                                self.channels.removeAll()
                                self.channels.append(channel)
                                print(self.channels)
                                print("\(channel.name)")
                                print(channel.channelUrl)
                                let session = URLSession.shared
                                let url = "https://api-2B2DA376-91B5-4604-9279-C0533F130126.sendbird.com/v3/group_channels/\(channel.channelUrl)"
                                print(url)
                                let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                                request.addValue("cf709ee2fa69a3823f90bdc98647c0d2e850d3cf", forHTTPHeaderField: "Api-Token")
                                request.httpMethod = "PUT"
                                let newname = "\(self.groupNameTxtFeild.text!) - GRP\(self.group_id)"
                                print(newname)
                                let params:[String: AnyObject] = ["name" : newname as AnyObject]
                                do{
                                    request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
                                    let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                                        if let response = response {
                                            let nsHTTPResponse = response as! HTTPURLResponse
                                            let statusCode = nsHTTPResponse.statusCode
                                            print ("status code = \(statusCode)")
                                        }
                                        if let error = error {
                                            print ("\(error)")
                                        }
                                        if let data = data {
                                            do{
                                                let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                                                print(jsonData)
                                                //   print (" deviceId= \(deviceId), mobileDeviceId= \(mobileDeviceId), deviceType= \(deviceType)")
                                            }catch _ {
                                                print ("the response is not well JSON formatted")
                                            }
                                        }
                                    })
                                    task.resume()
                                }catch _ {
                                    print ("Oops something happened buddy")
                                }
                                
                                
                            }else{
                                print("chanel isNot present")
                            }
                        }
                       
                        //sendbird end
                        self.view.makeToast("Group Updated successfully")
                        let d = self.drawer()
                        d!.setMain(identifier: "group", config: { (vc) in
                            if let nav = vc as? UINavigationController {
                                //  nav.viewControllers.first?.title = "Home"
                                UserDefaults.standard.set(false, forKey: "creategroup")
                                
                            }
                        })
                        ANLoader.hide()
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.view.makeToast("Please try again".localized())
                        ANLoader.hide()
                    }
                }
                
            }
        }
        
        task.resume()
        }
    }
    //to create new group
    func createGroupApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.createGroup
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "img=%@&name=%@&user_id=%@&desc=%@",self.imageBase64.addingPercentEncoding(withAllowedCharacters: charset as CharacterSet)!,groupNameTxtFeild.text!,userId,groupDescriptionTxtFeild.text!)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj as Any)
                var status = jsonObj?.value(forKey: "status") as! Int
                var group_ids = jsonObj?.value(forKey: "group_id") as! Int
                if(status == 1){
                      DispatchQueue.main.async {
                    self.view.makeToast("Group created successfully")
                     //sendbird
                        SBDGroupChannel.createChannel(withName: ("\(self.groupNameTxtFeild.text!) - GRP\(group_ids)"), isDistinct: false, userIds: [self.userId], coverUrl:"", data: "", customType: "") { (channel, error) in
                            print(channel?.name as Any)
                        }
                      //end
                        if(self.controller == "tagadeed"){
                            //Push to tag a deed
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tagADeed") as! UINavigationController
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                        }
                        else{
                            let d = self.drawer()
                            d!.setMain(identifier: "group", config: { (vc) in
                                if let nav = vc as? UINavigationController {
                                    //  nav.viewControllers.first?.title = "Home"
                                    UserDefaults.standard.set(false, forKey: "creategroup")
                                    
                                }
                            })
                        }
                     
                     ANLoader.hide()
                    }
                }
                else{
                      DispatchQueue.main.async {
                    self.view.makeToast("Please try again".localized())
                    ANLoader.hide()
                    }
                }
               
            }
        }
        
        task.resume()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
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
