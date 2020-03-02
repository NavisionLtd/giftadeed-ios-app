//
//  CreateCollaborationViewController.swift
//  GiftADeed
//
//  Created by Darshan on 5/24/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import ActionSheetPicker_3_0
import SendBirdSDK
import Localize_Swift
import SendBirdSDK

class CreateCollaborationViewController: UIViewController,UITextFieldDelegate {
    var groupArr = NSMutableArray()
    var groupListArr = NSMutableArray()
    var userId = ""
    var text = ""
    var collab_id = ""
     var collab_name = ""
  //   var channels: [SBDGroupChannel] = []
    //For group
    var needGroupMappingID = ""
    var needGroupTitle = ""
    @IBOutlet weak var selectGroup: UIButton!
    @IBOutlet weak var collaborationName: UITextField!
    @IBOutlet weak var collaborationDescription: UITextField!
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var nameAlertImg: UIImageView!
    @IBOutlet weak var nameAlertMsg: UILabel!
    @IBOutlet weak var descriptionAlertImg: UIImageView!
    @IBOutlet weak var descriptionAlertMsg: UILabel!
         var  name = ""
    //sendbird
     var channels: [SBDGroupChannel] = []
    fileprivate var myGroupChannelListQuery: SBDGroupChannelListQuery?
  @objc func setText()
    {
        self.groupName.text = "Select your group".localized()
        self.groupName.placeholder = "Select your group".localized()
    //    self.collaborationName.text = " Collaboration name".localized()
         self.collaborationName.placeholder = "Collaboration name".localized()
        self.saveBtn.setTitle("Save".localized(), for: .normal)
        self.collaborationDescription.placeholder = "Collaboration description".localized()
       // self.collaborationDescription.text = " Collaboration description".localized()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
               name = UserDefaults.standard.value(forKey: "Fname") as! String
downloadOwnGroupData()
          DispatchQueue.main.async{
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            if(self.text == "edit"){
                self.collabDetailApiCall()
                self.navigationItem.title = "Edit Collaboration".localized()
            }
            else{
            self.navigationItem.title = "Create Collaboration".localized()
            }
            
            self.saveBtn.layer.cornerRadius = 5
            self.groupName.addBottomBorder(UIColor.black, height: 0.5)
            self.collaborationName.addBottomBorder(UIColor.black, height: 0.5)
            self.collaborationDescription.addBottomBorder(UIColor.black, height: 0.5)
            self.nameAlertImg.isHidden = true
            self.nameAlertMsg.isHidden = true
            self.descriptionAlertImg.isHidden = true
            self.descriptionAlertMsg.isHidden = true
            self.collaborationName.delegate = self
            self.collaborationDescription.delegate = self
            self.setText()
        }
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        //sendbird
        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery?.limit = 10
        SBDMain.connect(withUserId: self.userId, completionHandler: { (user, error) in
            if error == nil {
                SBDMain.updateCurrentUserInfo(withNickname: self.name, profileUrl: nil, completionHandler: { (error) in
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
        // Do any additional setup after loading the view.
    }
   
    override func viewWillDisappear(_ animated: Bool) {
       // NotificationCenter.default.post(name: Notification.Name("collaboration"), object: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.collaborationName) {
            self.nameAlertImg.isHidden = true
            self.nameAlertMsg.isHidden = true
        } else if (textField == self.collaborationDescription) {
            self.nameAlertImg.isHidden = true
            self.nameAlertMsg.isHidden = true
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard range.location == 0 else {
            return true
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
    func collabDetailApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.collaboration_information
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "collaboration_id=%@",self.collab_id)
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
                
                var  collaboration_information = jsonObj?.value(forKey: "collaboration_information") as? NSDictionary
                print(collaboration_information!)
                  DispatchQueue.main.async{
                self.collaborationDescription.text = (collaboration_information?.value(forKey: "collaboration_description") as? String)!
                self.collaborationName.text = (collaboration_information?.value(forKey: "collaboration_name") as? String)!
            //    self.collaboration_start_date = (collaboration_information?.value(forKey: "collaboration_start_date") as? String)!
                    self.needGroupMappingID = (collaboration_information?.value(forKey: "group_id") as? String)!
                self.groupName.text = (collaboration_information?.value(forKey: "group_name") as? String)!
               // let user_id = collaboration_information?.value(forKey: "user_id") as? String
             //   self.user_name = (collaboration_information?.value(forKey: "user_name") as? String)!
                }
            }
        }
        
        task.resume()
    }
    @IBAction func selectGroupBtnPress(_ sender: UIButton) {
        if self.groupListArr.count == 0{
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Group list is empty.")
            return
        }
        ActionSheetStringPicker.show(withTitle: "Select Group",
                                     rows: self.groupListArr as! [Any] ,
                                     initialSelection: 0,
                                     doneBlock: {
                                        picker, indexe, values in
                                        DispatchQueue.main.async{
                                            
                                            self.groupName.text = values as? String
                                        }
                                        let item = self.groupArr[indexe]
                                        self.needGroupTitle = (item as AnyObject).value(forKey:"group_name") as! String
                                        self.needGroupMappingID = (item as AnyObject).value(forKey:"group_id") as! String
                                        
                                        print("\(self.needGroupTitle)\(self.needGroupMappingID)")
                                        
                                        if(self.needGroupTitle.count > 0){
                                            //   self.downloadCategoryData(mapId: self.needGroupMappingID)
                                        }else{}
                                        
                                        return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    @IBAction func saveBtnPress(_ sender: UIButton) {
        print(self.text)
      if(self.text != "edit")
      {
      
       
            userId = UserDefaults.standard.value(forKey: "User_ID") as! String
            ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
            let urlString = Constant.BASE_URL + Constant.create_collaboration
            let url:NSURL = NSURL(string: urlString)!
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            let paramString = String(format: "user_id=%@&group_id=%@&collaboration_name=%@&collaboration_description=%@",userId,needGroupMappingID,collaborationName.text!,collaborationDescription.text!)
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
                    print(jsonObj)
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        let success_message = jsonObj?.value(forKey: "success_message") as! String
                        let collaboration_id = jsonObj?.value(forKey: "collaboration_id") as! Int
                        DispatchQueue.main.async{
                            self.view.hideToast()
                            self.view.makeToast(success_message)
                            DispatchQueue.main.async{
                                //sendbird
                                SBDGroupChannel.createChannel(withName: ("\(self.collaborationName.text!) - CLB\(collaboration_id)"), isDistinct: false, userIds: [self.userId], coverUrl:"", data: "", customType: "") { (channel, error) in
                                    print(channel?.name as Any)
                                }
                                //end
                                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                                let d = self.drawer()
                                d!.setMain(identifier: "group", config: { (vc) in
                                    self.view.makeToast(success_message,duration:1)
                                })
                            }
                        }
                    }
                    else if (status == 0){
                        let validation_message = jsonObj?.value(forKey: "error_message") as! String
                        print(validation_message)
                        let validations = validation_message.components(separatedBy: "/")
                        print(validations)
                        DispatchQueue.main.async{
                            if(self.needGroupMappingID.count == 0){
                                
                                self.view.makeToast("Please select group")
                                
                            }
                            else if((self.collaborationName.text?.isEmpty)!){
                                
                                self.view.hideToast()
                                self.nameAlertImg.isHidden = false
                                self.nameAlertMsg.isHidden = false
                                self.nameAlertMsg.text = validations[0]
                                //  self.view.makeToast(validations[1])
                                
                            }
                            else if(self.collaborationDescription.text == ""){
                                
                                self.view.hideToast()
                                self.descriptionAlertImg.isHidden = false
                                self.descriptionAlertMsg.isHidden = false
                                self.descriptionAlertMsg.text = validations[0]
                                //   self.view.makeToast(validations[1])
                                
                            }
                            else{
                                self.view.hideToast()
                            }
                        }
                    }
                }
                
            }
            task.resume()

        }
      else{
        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.")
            }
        }else{
            userId = UserDefaults.standard.value(forKey: "User_ID") as! String
            ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
            let urlString = Constant.BASE_URL + Constant.edit_collaboration
            let url:NSURL = NSURL(string: urlString)!
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            //collab_id = 64 / group_id = 80
            let paramString = String(format: "collaboration_id=%@&group_id=%@&collaboration_name=%@&collaboration_description=%@",self.collab_id,needGroupMappingID,collaborationName.text!,collaborationDescription.text!)
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
                        self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
                    }
                    return
                }
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    print(jsonObj)
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        let success_message = jsonObj?.value(forKey: "success_message") as! String
                        //   let collaboration_id = jsonObj?.value(forKey: "collaboration_id") as! Int
                        DispatchQueue.main.async{
                            self.view.hideToast()
                            //Sendbird edit channel
                            var channel: SBDGroupChannel
                            //   self.channels.removeAll()
                            for item in self.channels {
                                channel = item as SBDGroupChannel
                                self.channels.append(channel)
                                print(self.channels)
                                print(channel.name)
                                print(channel.channelUrl)
                                let fullName   = "\(self.collab_name) - CLB\(self.collab_id)"
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
                                    let newname = "\(self.collaborationName.text!) - CLB\(self.collab_id)"
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
                            self.view.makeToast(success_message)
                            
                            DispatchQueue.main.async{
                                
                                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                                let d = self.drawer()
                                NotificationCenter.default.post(name: Notification.Name("fromcollab"), object: nil)
                                d!.setMain(identifier: "group", config: { (vc) in
                                    self.view.makeToast(success_message,duration:1)
                                })
                                
                                
                                
                            }
                        }
                        
                    }
                    else if (status == 0){
                        let validation_message = jsonObj?.value(forKey: "error_message") as! String
                        print(validation_message)
                        let validations = validation_message.components(separatedBy: "/")
                        print(validations)
                        DispatchQueue.main.async{
                            if(self.needGroupMappingID.count == 0){
                                
                                self.view.makeToast("Please select group")
                                
                            }
                            else if((self.collaborationName.text?.isEmpty)!){
                                
                                self.view.hideToast()
                                self.nameAlertImg.isHidden = false
                                self.nameAlertMsg.isHidden = false
                                self.nameAlertMsg.text = validations[1]
                                //  self.view.makeToast(validations[1])
                                
                            }
                            else if(self.collaborationDescription.text == ""){
                                
                                self.view.hideToast()
                                self.descriptionAlertImg.isHidden = false
                                self.descriptionAlertMsg.isHidden = false
                                self.descriptionAlertMsg.text = validations[1]
                                //   self.view.makeToast(validations[1])
                                
                            }
                            else{
                                self.view.hideToast()
                            }
                        }
                    }
                }
                
            }
            task.resume()
        }
        }
       
    }
    func downloadOwnGroupData (){
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.owned_groups
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@",userId)
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                
                self.groupListArr.removeAllObjects();
                self.groupArr.removeAllObjects();
                
                for item in jsonObj! {
                    
                    do {
                        
                        try self.groupListArr.add((item as AnyObject).value(forKey:"group_name") as! String)
                        
                        let groupItem = item as? NSDictionary
                        try self.groupArr.add(groupItem!)
                        
                    } catch {
                        // Error Handling
                        print("Some error occured.")
                    }
                    
                }
                
            }
            
        }
        task.resume()
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
