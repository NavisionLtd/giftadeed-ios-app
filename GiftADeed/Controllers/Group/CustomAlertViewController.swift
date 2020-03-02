//
//  CustomAlertViewController.swift
//  EzPopup_Example
//
//  Created by Huy Nguyen on 6/4/18.
//  Copyright © 2018 CocoaPods. All rights reserved.

import UIKit
import ANLoader
import SendBirdSDK
import Localize_Swift
struct members {
    let member_name : String
    let member_id : String
    let member_email : String
    let member_joined : Int
}
class CustomAlertViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var addMembersNavBar: UILabel!
    var group_id = ""
    var group_name = ""
    var userId = ""
    let defaults = UserDefaults.standard
    var membersArray = [members]()
    //sendbird
     var channels: [SBDGroupChannel] = []
    fileprivate var myGroupChannelListQuery: SBDGroupChannelListQuery?
    @IBOutlet weak var emailIdTextFeild: FloatLabelTextField!
    @IBOutlet weak var alreadyMemberLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var emailIdLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    static func instantiate() -> CustomAlertViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(CustomAlertViewController.self)") as? CustomAlertViewController
    }
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    @IBAction func searchBtnPress(_ sender: UIButton) {
        if(isValidEmail(testStr: emailIdTextFeild.text!)){
            self.view.hideAllToasts()
            searchUserToAddApiCall()
        }
        else{
            self.view.makeToast("Please enter valid Email-id".localized())
        }
      
    }
    @IBAction func addBtnPress(_ sender: UIButton) {
        addMemberApiCall()
    }
    @IBAction func viewMembersBtnPress(_ sender: UIButton) {
//        let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "GroupMemberListViewController") as? GroupMemberListViewController
//        memberViewController!.group_id = self.group_id
//        self.present(memberViewController!, animated: true, completion: nil)
//        self.navigationController?.pushViewController(memberViewController!, animated: true)
//        print("ONE")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addMembersNavBar.text = "Add members".localized()
        self.searchBtn.setTitle("Search".localized(), for: .normal)
        self.addBtn.setTitle("Add".localized(), for: .normal)
        self.emailIdTextFeild.placeholder = "Search email*".localized()
         searchBtn.layer.cornerRadius = 5
        addBtn.layer.cornerRadius = 5
        emailIdTextFeild.delegate = self
        //get userid to create group and send data to API
        userId = defaults.value(forKey: "User_ID") as! String
        emailIdTextFeild.setBottomBorder()
        searchBtn.layer.cornerRadius = 5
        addBtn.layer.cornerRadius = 5
         self.addBtn.isHidden = true
        self.emailIdLbl.isHidden = true
        self.alreadyMemberLbl.isHidden = true
        let  name = UserDefaults.standard.value(forKey: "Fname") as! String
        
        //Sendbirds
        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery?.limit = 10
      //  ANLoader.showLoading()
     //   memberId = UserDefaults.standard.string(forKey: "memberid") ?? "0"
     //   let name = UserDefaults.standard.string(forKey: "first_Name")
      //   self.loadChannels()
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
        //end
    }
    fileprivate func loadChannels() {
        if self.myGroupChannelListQuery?.isLoading() == true {
            return
        }
        
        if self.myGroupChannelListQuery?.hasNext == false {
            return
        }
        
        self.myGroupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
//                if self.refreshControl?.isRefreshing == true {
//                    self.refreshControl?.endRefreshing()
//                }
                
                return
            }
            
            if channels == nil || channels!.count == 0 {
                return
            }
            
            for item in channels! {
                let channel = item as SBDGroupChannel
                self.channels.append(channel)
                
            }
            
            DispatchQueue.main.async(execute: {
                print(self.channels)
                
                // ANLoader.hide()
            })
        })
    }
    //validation of textfeilds
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == emailIdTextFeild){
            if string.characters.count == 0 {
                return true
            }
            let currentText = emailIdTextFeild.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let newString = (currentText as NSString).replacingCharacters(in: range, with: string) as NSString
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_.@0123456789") &&
                newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 && newString.length <= 55
        }
      
        else{
            return true
        }
    }
    //validation end
    // MARK: Actions
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func searchUserToAddApiCall(){
       self.membersArray.removeAll()
        self.addBtn.isHidden = true
        self.emailIdLbl.isHidden = true
        self.alreadyMemberLbl.isHidden = true
        //user_id(int), group_id(int),Email
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.searchUser
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@&group_id=%@&email=%@",userId,group_id,emailIdTextFeild.text!)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            //[{user_id, name, email, joined: 0/1}]
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async {
                    
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                print(jsonObj as Any)
                if(jsonObj?.count == 0){ DispatchQueue.main.async{
                        self.emailIdLbl.isHidden = false
                     self.alreadyMemberLbl.isHidden = true
                     self.addBtn.isHidden = true
                    self.emailIdLbl.text = "No Record's Found".localized()
                    ANLoader.hide()
                    }
                }
                else{
                    for values in jsonObj!{
                        
                        let member_id = (values as AnyObject).value(forKey: "user_id") as! String
                        let name = (values as AnyObject).value(forKey: "name") as! String
                        let email = (values as AnyObject).value(forKey: "email") as! String
                        let joined = (values as AnyObject).value(forKey: "joined") as! Int
                        
                        if(joined == 1){
                            //alreay member
                            DispatchQueue.main.async{
                                self.emailIdLbl.isHidden = false
                                self.emailIdLbl.text = email
                                self.alreadyMemberLbl.isHidden = false
                                self.alreadyMemberLbl.text = "Already Joined".localized()
                                self.addBtn.isHidden = true
                                ANLoader.hide()
                            }
                            
                        }
                        else{
                            DispatchQueue.main.async{
                                self.emailIdLbl.isHidden = false
                                self.emailIdLbl.text = email
                                self.alreadyMemberLbl.isHidden = true
                                self.addBtn.isHidden = false
                                ANLoader.hide()
                            }
                           
                        }
                        let member = members(member_name: name, member_id: member_id, member_email: email, member_joined: joined)
                        self.membersArray.append(member)
                    }
                }
                
               
          
            }
            
            DispatchQueue.main.async{
   
            }
            
            
        }
        task.resume()
        
    }
    func addMemberApiCall(){
    
        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.".localized())
            }
        }
        else{
            ANLoader.showLoading("Loading", disableUI: true)
            
            let urlString = Constant.BASE_URL + Constant.addUser
            
            let url:NSURL = NSURL(string: urlString)!
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            var paramString = ""
            print(membersArray)
            for values in membersArray{
                let member = values.member_id
                
                paramString = String(format: "user_id=%@&group_id=%@&member_id=%@",userId,group_id,member)
            }
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request as URLRequest) {
                (
                //[{user_id, name, email, joined: 0/1}]
                data, response, error) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    ANLoader.hide()
                }
                
                guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                    
                    DispatchQueue.main.async {
                        
                    }
                    return
                }
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    print(jsonObj as Any)
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        DispatchQueue.main.async{
                            ANLoader.hide()
                            print(self.channels)
                            //get list of all channels if joining req club name id equal to channel name then create coode for joining request
                            var channel: SBDGroupChannel
                            //   self.channels.removeAll()
                            for item in self.channels {
                                channel = item as SBDGroupChannel
                                self.channels.append(channel)
                                print(self.channels)
                                print(channel.name)
                                print(channel.channelUrl)
                                let fullName   = "\(self.group_name) - GRP-\(self.group_id)"
                                print("\(channel.name)\(fullName)")
                                if(channel.name == fullName){
                                    print("chanel is present")
                                    self.channels.removeAll()
                                    self.channels.append(channel)
                                    print(self.channels)
                                    print("\(channel.name)\(self.membersArray)")
                                    print(channel.channelUrl)
                                    for values in self.membersArray{
                                        let member = values.member_id
                                        print(member)
                                        channel.inviteUserIds([member]) { (error) in
                                            guard error == nil else {   // Error.
                                                return
                                            }
                                            
                                            // ...
                                        }
                                        // In case of accepting an invitation
                                        channel.acceptInvitation { (error) in
                                            guard error == nil else {   // Error.
                                                return
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                }else{
                                    print("chanel isNot present")
                                }
                            }
                            self.view.hideAllToasts()
                            self.view.makeToast("You have Successfully joined this group".localized())
                            self.addBtn.isHidden = true
                            self.emailIdLbl.isHidden = true
                            self.alreadyMemberLbl.isHidden = true
                            self.emailIdTextFeild.text = ""
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            ANLoader.hide()
                            self.view.hideAllToasts()
                            self.view.makeToast("Something went wrong ! Please try again.".localized())
                        }
                    }
                }
                
                DispatchQueue.main.async{
                    
                }
                
                
            }
            task.resume()
        }
        }
        
       
}
