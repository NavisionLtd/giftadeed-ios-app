//
//  InviteGroupCreatorsViewController.swift
//  GiftADeed
//
//  Created by Darshan on 5/28/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import SendBirdSDK
import Localize_Swift
struct listGroupMembers {
    let member_name : String
    let member_id : String
     let member_group : String
    let member_lastname : String
   // let invited_already : String
   //  let member_privilege : String
}
extension InviteGroupCreatorsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchController.searchBar.text {
            filterRowsForSearchedText(term)
        }
    }
}
class InviteGroupCreatorsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var inviteBtn: UIButton!
    var channels: [SBDGroupChannel] = []
    var collab_name = ""
    var userId = ""
    var collab_id = ""
    let defaults = UserDefaults.standard
    var membersArray = [listGroupMembers]()
    var filteredModels = [listGroupMembers]()
    var selectedIds = NSMutableArray()
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var inviteGroupTbl: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
     self.inviteBtn.setTitle("INVITE".localized(), for: .normal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:" ", style:.plain, target:nil, action:nil)
        self.navigationItem.title = "Invite group creators".localized()
        //get userid to create group and send data to API
        userId = defaults.value(forKey: "User_ID") as! String
          viewMemberListApiCall()
        self.inviteGroupTbl.allowsMultipleSelection = true
        self.inviteGroupTbl.allowsMultipleSelectionDuringEditing = true
  setupSearchController()
    //    inviteGroupTbl.estimatedRowHeight = 90.0
      //  inviteGroupTbl.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }
//     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    func setupSearchController() {
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.barTintColor = UIColor(white: 0.9, alpha: 0.9)
        searchController.searchBar.placeholder = "Search by Group name*".localized()
        searchController.hidesNavigationBarDuringPresentation = false
        
        inviteGroupTbl.tableHeaderView = searchController.searchBar
    }
    
    
    
    func filterRowsForSearchedText(_ searchText: String) {
        filteredModels = membersArray.filter({( model : listGroupMembers) -> Bool in
            return model.member_name.lowercased().contains(searchText.lowercased())||model.member_group.lowercased().contains(searchText.lowercased())
        })
        inviteGroupTbl.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return membersArray.count
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredModels.count
        }
        
        return membersArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CollaborationGroupInviteTableViewCell
      
        let model: listGroupMembers
        if searchController.isActive && searchController.searchBar.text != "" {
            model = filteredModels[indexPath.row]
        } else {
            model = membersArray[indexPath.row]
        }
        cell.userName.text = model.member_name
        cell.usersGroupName.text = model.member_group
        cell.userGroupId.text = model.member_id
      
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor.blue
            NSLog("You selected cell #\(indexPath.row)!")
            let cell = tableView.cellForRow(at: indexPath) as! CollaborationGroupInviteTableViewCell
            print(cell.userGroupId?.text)
            let id = cell.userGroupId?.text as! String
            self.selectedIds.add(id)
              print(self.selectedIds)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            cell.tintColor = UIColor.clear
            NSLog("You deselected cell #\(indexPath.row)!")
            let cell = tableView.cellForRow(at: indexPath) as! CollaborationGroupInviteTableViewCell
            let id = cell.userGroupId?.text as! String
            self.selectedIds.remove(id)
            print(self.selectedIds)
        }
    }
    //Api call to display all members in group
    func viewMemberListApiCall(){
        //user_id(int), member_id(int), group_id(int)
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.group_creators_list
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        var paramString = ""
        
        
        paramString = String(format: "user_id=%@&collaboration_id=%@",userId,collab_id)
        
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
                    let group_creators_list = jsonObj?.value(forKey: "group_creators_list") as! NSArray
                    for item in group_creators_list{
                        let group_name = (item as AnyObject).value(forKey: "group_name") as! String
                        let user_id = (item as AnyObject).value(forKey: "user_id") as! String
                        let first_name = (item as AnyObject).value(forKey: "first_name") as! String
                        let last_name = (item as AnyObject).value(forKey: "last_name") as! String
                        let invited_already = (item as AnyObject).value(forKey: "invited_already") as! String
                        let collab = listGroupMembers(member_name: first_name, member_id: user_id, member_group: group_name, member_lastname: last_name)
                        if(invited_already == "YES"){
                            
                        }
                        else{
                            self.membersArray.append(collab)
                        }
                        
                    }
                }
            }
            DispatchQueue.main.async{
                self.inviteGroupTbl.reloadData()
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

    @IBAction func inviteBtnPress(_ sender: UIButton) {
        //collaboration_id,group_creators
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.invite_group_creators
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        var paramString = ""
        let id = selectedIds.componentsJoined(by: ",")
        
        paramString = String(format: "group_creators=%@&collaboration_id=%@",id,collab_id)
        
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
                    let success_message = jsonObj?.value(forKey: "success_message") as! String
                     DispatchQueue.main.async {
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
                            let fullName   = "\(self.collab_name) - CLB-\(self.collab_id)"
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
//                                    // In case of accepting an invitation
//                                    channel.acceptInvitation { (error) in
//                                        guard error == nil else {   // Error.
//                                            return
//                                        }
//                                    }
                                    
                                }
                                
                                
                            }else{
                                print("chanel isNot present")
                            }
                        }
                    self.view.makeToast(success_message)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                         self.navigationController?.popViewController(animated: true)
                        // Put your code which should be executed with a delay here
                    })
                    DispatchQueue.main.async{
                   
//                        self.membersArray.removeAll()
//                        self.viewMemberListApiCall()
                      //  self.inviteGroupTbl.reloadData()
                    }
                }
                else if(status == 0){
                    
                    let error_message = jsonObj?.value(forKey: "error_message") as! String
                     DispatchQueue.main.async {
                    self.view.makeToast(error_message)
                    }
                }
            }
           
        }
        task.resume()
    }
}
