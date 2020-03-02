//
//  CollaborationDetailViewController.swift
//  GiftADeed
//
//  Created by Darshan on 5/28/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import PopOverMenu
import SendBirdSDK

class CollaborationDetailViewController: UIViewController,UIAdaptivePresentationControllerDelegate {
    //sendbird
    fileprivate var channels: [SBDGroupChannel] = []
    fileprivate var myGroupChannelListQuery: SBDGroupChannelListQuery?
 var collab_id = ""
    var collab_name = ""
    var collab_role = ""
    var collaboration_description = ""
    var collaboration_name = ""
    var collaboration_start_date = ""
    var user_name = ""
    var group_name = ""
     var userId = ""
     let defaults = UserDefaults.standard
    @IBOutlet weak var collabDescription: UILabel!
    @IBOutlet weak var collabCreatedAt: UILabel!
    @IBOutlet weak var collabName: UILabel!
    @IBOutlet weak var collabCreatedBy: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Collab Details".localized()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //get userid to create group and send data to API
        userId = defaults.value(forKey: "User_ID") as! String
collabDetailApiCall()
        // Do any additional setup after loading the view.
        //Sendbirds
        let  name = UserDefaults.standard.value(forKey: "Fname") as! String
        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery?.limit = 10
        ANLoader.showLoading()
        //   memberId = UserDefaults.standard.string(forKey: "memberid") ?? "0"
        //   let name = UserDefaults.standard.string(forKey: "first_Name")
        self.loadChannels()
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
                
                ANLoader.hide()
            })
        })
    }
    @IBAction func navBarPress(_ sender: UIBarButtonItem) {
        if(self.collab_role == "C"){
            let titles = ["Invite group creators".localized(),"view member list".localized(),"Edit collab".localized(),"Delete Collab".localized()]
            let popOverViewController = PopOverViewController.instantiate()
            popOverViewController.setTitles(titles)
            popOverViewController.popoverPresentationController?.barButtonItem = sender
            popOverViewController.preferredContentSize = CGSize(width: 200, height:200)
            popOverViewController.presentationController?.delegate = self
            popOverViewController.completionHandler = { selectRow in
                switch (selectRow) {
                case 0:
                    let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "InviteGroupCreatorsViewController") as? InviteGroupCreatorsViewController
                    memberViewController!.collab_id = self.collab_id
                    memberViewController!.collab_name = self.collab_name
                    memberViewController!.channels = self.channels
                    self.navigationController?.pushViewController(memberViewController!, animated: true)
                    print("ZERO")
                    break
                case 1:
                    //push group member list view
                    let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CollaborationMembersListViewController") as? CollaborationMembersListViewController
                    memberViewController!.group_id = self.collab_id
                    memberViewController!.collab_name = self.collab_name
                    memberViewController!.channels = self.channels
                    // memberViewController!.text = "collab"
                    self.navigationController?.pushViewController(memberViewController!, animated: true)
                    break
                case 2:
                    let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateCollaborationViewController") as? CreateCollaborationViewController
                    memberViewController!.text = "edit"
                    memberViewController!.collab_id = self.collab_id
                  //  memberViewController!.collab_id = self.collab_id
                    memberViewController!.collab_name = self.collab_name
                    memberViewController!.channels = self.channels
                    self.navigationController?.pushViewController(memberViewController!, animated: true)
                    break
                case 3:
                    let alert = UIAlertController(title: "Delete".localized(), message: "Do you really want to delete this collaboration?".localized(), preferredStyle: .alert)
                    
                    let ok = UIAlertAction(title: "Ok".localized(), style: .default, handler: { action in
                        self.collabDeleteApiCall()
                    })
                    alert.addAction(ok)
                    let cancel = UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
                        alert.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(cancel)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true)
                    })
                    
                default:
                    break
                }
                
            };
            present(popOverViewController, animated: true, completion: nil)
        }else{
            let titles = ["view member list".localized(),"Exit from Collab".localized()]
            let popOverViewController = PopOverViewController.instantiate()
            popOverViewController.setTitles(titles)
            popOverViewController.popoverPresentationController?.barButtonItem = sender
            popOverViewController.preferredContentSize = CGSize(width: 200, height:100)
            popOverViewController.presentationController?.delegate = self
            popOverViewController.completionHandler = { selectRow in
                switch (selectRow) {
                case 0:
                    //push group member list view
                    let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CollaborationMembersListViewController") as? CollaborationMembersListViewController
                    memberViewController!.group_id = self.collab_id
                    memberViewController!.collab_name = self.collab_name
                    memberViewController!.channels = self.channels
                    // memberViewController!.text = "collab"
                    self.navigationController?.pushViewController(memberViewController!, animated: true)
                    break
                case 1:
                    self.collabMemberDeleteApiCall(user_id: self.userId)
                    break
               
                    
                default:
                    break
                }
                
            };
            present(popOverViewController, animated: true, completion: nil)
        }
    
    }
    func collabMemberDeleteApiCall(user_id : String){
        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.".localized())
            }
        }
        else{
            ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
            
            let urlString = Constant.BASE_URL + Constant.remove_member_from_collaboration
            
            let url:NSURL = NSURL(string: urlString)!
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            
            let charset = NSMutableCharacterSet.alphanumeric()
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            let paramString = String(format: "collaboration_id=%@&user_id=%@",self.collab_id,user_id)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request as URLRequest) {
                (data, response, error) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    ANLoader.hide()
                }
                
                guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                    
                    DispatchQueue.main.async{
                        
                        self.view.hideAllToasts()
                        self.view.makeToast(Validation.ERROR.localized())
                    }
                    return
                }
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    print(jsonObj!)
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        DispatchQueue.main.async{
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
                                    
                                    let url = "https://api-2B2DA376-91B5-4604-9279-C0533F130126.sendbird.com/v3/group_channels/\(channel.channelUrl)/leave"
                                    print(url)
                                    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                                    request.addValue("cf709ee2fa69a3823f90bdc98647c0d2e850d3cf", forHTTPHeaderField: "Api-Token")
                                    request.httpMethod = "PUT"
                                    let newname = "\(self.collab_name) - CLB\(self.collab_id)"
                                    print(newname)
                                    
                                    //                                        {
                                    //                                            "user_ids": ["Philip", "Matthew", "Janna"]
                                    //                                    }
                                    //    let params:[String:AnyObject] = ["user_ids" : "563" as AnyObject]
                                    var array = [user_id]
                                    var params = NSMutableDictionary()
                                    params.setValue(array, forKey:"user_ids")
                                    print(params)
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
                            self.view.makeToast("Member Removed successfully".localized(),duration:1)
                            let d = self.drawer()
                            d!.setMain(identifier: "group", config: { (vc) in
                                
                            })
                        }
                        
                    }
                    else{
                        self.view.makeToast("Please try again.".localized())
                    }
                }
                DispatchQueue.main.async{
                    
                }
            }
            
            task.resume()
        }
       
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    func collabDeleteApiCall(){
        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.".localized())
            }
        }
        else{
            ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
            
            let urlString = Constant.BASE_URL + Constant.delete_collaboration
            
            let url:NSURL = NSURL(string: urlString)!
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            
            let charset = NSMutableCharacterSet.alphanumeric()
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            let paramString = String(format: "collaboration_id=%@",collab_id)
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
                    print(jsonObj)
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        let success_messgae = jsonObj?.value(forKey: "success_messgae") as! String
                        DispatchQueue.main.async{
                            //start sendbird
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
                                    request.httpMethod = "DELETE"
                                    let newname = "\(self.collab_name) - CLB\(self.collab_id)"
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
                            //end sendbird
                            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                            let d = self.drawer()
                            d!.setMain(identifier: "group", config: { (vc) in
                                self.view.makeToast(success_messgae,duration:1)
                            })
                        }
                        // self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        //                    let d = self.drawer()
                        //                    d!.setMain(identifier: "group", config: { (vc) in
                        //
                        //                    })
                    }
                    else{
                        self.view.makeToast("Please ry again.")
                    }
                }
                DispatchQueue.main.async{
                    
                }
            }
            
            task.resume()
        }
        
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
        let paramString = String(format: "collaboration_id=%@",collab_id)
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
                self.collaboration_description = (collaboration_information?.value(forKey: "collaboration_description") as? String)!
                 self.collaboration_name = (collaboration_information?.value(forKey: "collaboration_name") as? String)!
                 self.collaboration_start_date = (collaboration_information?.value(forKey: "collaboration_start_date") as? String)!
                let group_id = collaboration_information?.value(forKey: "group_id") as? String
                 self.group_name = (collaboration_information?.value(forKey: "group_name") as? String)!
                let user_id = collaboration_information?.value(forKey: "user_id") as? String
                 self.user_name = (collaboration_information?.value(forKey: "user_name") as? String)!
           
            }
            DispatchQueue.main.async{
                self.collabName.text = self.collaboration_name
               // self.collabCreatedBy.text =  String(format: "Created by : %@(%@)",self.group_name,self.user_name)
               // self.collabCreatedAt.text =   String(format: "Created at : %@",self.collaboration_start_date)
                //self.collabDescription.text =   String(format: "Description : %@",self.collaboration_description)
                let text = "Created by :"
                let text1 = "Created at :"
                let text2 = "Description :"
                
                self.collabCreatedBy.attributedText = self.attributedText(withString: String(format: "\(text.localized()) %@(%@)",self.group_name,self.user_name), boldString: "Created by :", font: self.collabCreatedBy.font)
                self.collabCreatedAt.attributedText = self.attributedText(withString: String(format: "\(text1.localized()) %@",self.collaboration_start_date), boldString: "Created at :", font: self.collabCreatedAt.font)
                 self.collabDescription.attributedText = self.attributedText(withString: String(format: "\(text2.localized()) %@",self.collaboration_description), boldString: "Description :", font: self.collabDescription.font)
            }
        }
        
        task.resume()
    }

    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("collaboration"), object: nil)
    }
}
