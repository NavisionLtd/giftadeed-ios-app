//
//  CollaborationMembersListViewController.swift
//  GiftADeed
//
//  Created by Darshan on 5/30/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import SendBirdSDK

extension CollaborationMembersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchController.searchBar.text {
            filterRowsForSearchedText(term)
        }
    }
}
struct CollablistMembers {
    let first_name : String
    let user_role : String
    let last_name : String
    let user_id : String
    let group_name : String
    let coll_id : String
}
class CollaborationMembersListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CellRemoveSubclassDelegate {
    func deleteButtonTapped(name: String) {
        self.collabMemberDeleteApiCall(user_id: name)
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
            let paramString = String(format: "collaboration_id=%@&user_id=%@",self.group_id,user_id)
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
                        //Sendbird edit channel
                        var channel: SBDGroupChannel
                        //   self.channels.removeAll()
                        for item in self.channels {
                            channel = item as SBDGroupChannel
                            self.channels.append(channel)
                            print(self.channels)
                            print(channel.name)
                            print(channel.channelUrl)
                            let fullName   = "\(self.collab_name) - CLB\(self.group_id)"
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
                                let newname = "\(self.collab_name) - CLB\(self.group_id)"
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
                        //                    let d = self.drawer()
                        //                    d!.setMain(identifier: "group", config: { (vc) in
                        //
                        //                    })
                    }
                    else{
                        self.view.makeToast("Please ry again.".localized())
                    }
                }
                DispatchQueue.main.async{
                    self.membersArray.removeAll()
                    self.viewDidLoad()
                    // self.collaborationMemberListTbl.reloadData()
                }
            }
            
            task.resume()
        }
       
    }

    @IBOutlet weak var collaborationMemberListTbl: UITableView!
    var membersArray = [CollablistMembers]()
    var filteredModels = [CollablistMembers]()
    let searchController = UISearchController(searchResultsController: nil)
    var group_id = ""
    var collab_name = ""
    var userId = ""
    let defaults = UserDefaults.standard
    var channels: [SBDGroupChannel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:" ", style:.plain, target:nil, action:nil)
        self.navigationItem.title = "Member List".localized()
        self.collaborationMemberListTbl.tableFooterView = UIView()
        collaborationMemberListTbl.separatorColor = UIColor.black
        collaborationMemberListTbl.layoutMargins = UIEdgeInsets.zero
        collaborationMemberListTbl.separatorInset = UIEdgeInsets.zero
        //get userid to create group and send data to API
        userId = defaults.value(forKey: "User_ID") as! String
//        //register cell
//        collaborationMemberListTbl.register(UINib(nibName: "MemberListTableViewCells", bundle: nil), forCellReuseIdentifier: "cell")
        self.viewcollaborationMemberListApiCall()
        setupSearchController()
        collaborationMemberListTbl.rowHeight = UITableViewAutomaticDimension
        collaborationMemberListTbl.estimatedRowHeight = 120
        // Do any additional setup after loading the view.
    }
    func setupSearchController() {
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.barTintColor = UIColor(white: 0.9, alpha: 0.9)
        searchController.searchBar.placeholder = "Search by Member name or email".localized()
        searchController.hidesNavigationBarDuringPresentation = false
        collaborationMemberListTbl.tableHeaderView = searchController.searchBar
    }
    func filterRowsForSearchedText(_ searchText: String) {
        filteredModels = membersArray.filter({( model : CollablistMembers) -> Bool in
            return model.first_name.lowercased().contains(searchText.lowercased())||model.group_name.lowercased().contains(searchText.lowercased())
        })
        collaborationMemberListTbl.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return membersArray.count
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredModels.count
        }
        
        return membersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CollaborationMemberListTableViewCell
    let value = membersArray[indexPath.row]
        cell.memberName.text = ("\(value.first_name)\(value.last_name)")
        cell.membersGroupName.text = value.group_name
        let role = value.user_role
        if(role == "C")
        {
            cell.memberRole.text = "Creator".localized()
            let url = UserDefaults.standard.string(forKey: "userimg")
            cell.memberImg.sd_setImage(with: URL(string: url!), placeholderImage: UIImage(named: "about_app"))
            cell.removeBtn.isHidden = true
        }
        else{
             cell.removeBtn.isHidden = false
            cell.memberRole.text = "Member".localized()
        }
        cell.idLbl.text = value.user_id
        cell.delegate = self
        cell.memberRole.layer.borderWidth = 1.0
        cell.memberRole.layer.borderColor  = UIColor.orange.cgColor
        cell.memberRole.layer.cornerRadius = 15
        cell.memberImg.layer.borderWidth = 0.5
        cell.memberImg.layer.masksToBounds = false
        cell.memberImg.layer.borderColor = UIColor.black.cgColor
        cell.memberImg.layer.cornerRadius = cell.memberImg.frame.height/2
        cell.memberImg.clipsToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    //View collaboration members
    func viewcollaborationMemberListApiCall(){
        //user_id(int), member_id(int), group_id(int)
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.collaboration_members_list
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        var paramString = ""
        
           paramString = String(format: "collaboration_id=%@",self.group_id)

        
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
                    let collaboration_members_list = jsonObj?.value(forKey: "collaboration_members_list") as! NSArray
                    for items in collaboration_members_list{
                        let first_name = (items as AnyObject).value(forKey: "first_name") as! String
                        let last_name = (items as AnyObject).value(forKey: "last_name") as! String
                        let group_name = (items as AnyObject).value(forKey: "group_name") as! String
                        let user_id = (items as AnyObject).value(forKey: "user_id") as! String
                        let user_role = (items as AnyObject).value(forKey: "user_role") as! String
                        let collab = CollablistMembers(first_name: first_name, user_role: user_role, last_name: last_name, user_id: user_id, group_name: group_name, coll_id: "0")
                        self.membersArray.append(collab)
                    }
                }
            }
            
            DispatchQueue.main.async{
                 self.collaborationMemberListTbl.reloadData()
            }
            
            
        }
        task.resume()
    }

}
