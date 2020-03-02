//
//  GroupMemberListViewController.swift
//  GiftADeed
//
//  Created by Darshan on 2/19/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import SDWebImage
import MMDrawController
import EzPopup
import SendBirdSDK
import Localize_Swift
extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}
extension GroupMemberListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchController.searchBar.text {
            filterRowsForSearchedText(term)
        }
    }
}
extension NSArray{
    //sorting- ascending
    func ascendingArrayWithKeyValue(key:String) -> NSArray{
        let ns = NSSortDescriptor.init(key: key, ascending: true)
        let aa = NSArray(object: ns)
        let arrResult = self.sortedArray(using: aa as! [NSSortDescriptor])
        return arrResult as NSArray
    }
    
    //sorting - descending
    func discendingArrayWithKeyValue(key:String) -> NSArray{
        let ns = NSSortDescriptor.init(key: key, ascending: false)
        let aa = NSArray(object: ns)
        let arrResult = self.sortedArray(using: aa as! [NSSortDescriptor])
        return arrResult as NSArray
    }
}
extension GroupMemberListViewController: NumberPickerViewControllerDelegate {
    func numberPickerViewController(sender: NumberPickerViewController, didSelectNumber number: Int, didSelectedMemberId: String,menuOption: String) {
        dismiss(animated: true) {
            let alertController = UIAlertController(title: "Good luck", message: "Good luck with your number \(number)", preferredStyle: .alert)
            if(number == 0){
                // Create the alert controller
                let alertController = UIAlertController(title: "Remove member".localized(), message: "Do you want to remove this member?".localized(), preferredStyle: .alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
                    self.removeMemberApiCall(id:didSelectedMemberId )
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    alertController.dismiss(animated: true, completion: nil)
                    NSLog("Cancel Pressed")
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.present(alertController, animated: true, completion: nil)
                
            }
            else if(number == 1){
                print(menuOption)
                if(menuOption == "Admin"){
                    //admin member
                    // Create the alert controller
                    let alertController = UIAlertController(title: "Dismiss admin role to member".localized(), message: "Do you want to remove admin role from this member?".localized(), preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                        self.removeAdminToMemberApiCall(id:didSelectedMemberId )
                    }
                    let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        alertController.dismiss(animated: true, completion: nil)
                        NSLog("Cancel Pressed")
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)}
                else{
                    //genral member
                    // Create the alert controller
                    let alertController = UIAlertController(title: "Assign admin role to Member".localized(), message: "Do you want to assign admin role to this member?".localized(), preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                        self.assignAdminToMemberApiCall(id:didSelectedMemberId )
                    }
                    let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        alertController.dismiss(animated: true, completion: nil)
                        NSLog("Cancel Pressed")
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)}
                }
                
               
             
            }
    }
}
struct listMembers {
    let member_name : String
    let member_id : String
    let member_email : String
    let tot_member : Int
    let member_privilege : String
}
class GroupMemberListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,customAction,SBDChannelDelegate,SBDConnectionDelegate{
 
//delegate method defination from customcell
    func didPressMoreOptionsButton(sender: UIButton, memberids: String,memberRoles: String) {
        guard let pickerVC = pickerVC else { return }
        pickerVC.delegate = self
        let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 250, popupHeight: 80)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 5
        if(memberRoles == "Admin"){
            pickerVC.adminOrmember = "Admin"
            pickerVC.menu.removeAll()
             pickerVC.menu = ["Remove member".localized(),"Dismiss admin".localized()]
            pickerVC.tableView.reloadData()
        }else{
            pickerVC.adminOrmember = "Member"
            pickerVC.menu.removeAll()
              pickerVC.menu = ["Remove member".localized(),"Make admin".localized()]
            pickerVC.tableView.reloadData()
        }
        pickerVC.selectedMemberId = memberids
        present(popupVC, animated: true, completion: nil)
    }
    //sendbird
    var channels: [SBDGroupChannel] = []
    let pickerVC = NumberPickerViewController.instantiate()
    var membersArray = [listMembers]()
    var filteredModels = [listMembers]()
    let searchController = UISearchController(searchResultsController: nil)
    var group_id = ""
    var userId = ""
    let defaults = UserDefaults.standard
    var text = ""
    var group_name = ""
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return membersArray.count
//        if searchController.isActive && searchController.searchBar.text != "" {
//            return filteredModels.count
//        }
//
//        return membersArray.count
        var numOfSections: Int = 0
        if membersArray.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
            if searchController.isActive && searchController.searchBar.text != "" {
                            return filteredModels.count
                        }
            
                        return membersArray.count
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data found".localized()
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberListTableViewCells
        /*
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         
         let model: Model
         if searchController.isActive && searchController.searchBar.text != "" {
         model = filteredModels[indexPath.row]
         } else {
         model = models[indexPath.row]
         }
         cell.textLabel!.text = model.movie
         cell.detailTextLabel!.text = model.genre
         */
         let model: listMembers
        if searchController.isActive && searchController.searchBar.text != "" {
            model = filteredModels[indexPath.row]
        } else {
            model = membersArray[indexPath.row]
        }
        cell.cellDelegate = self
        cell.dotMenuBtn.tag = indexPath.row
        let values = membersArray[indexPath.row]
        cell.memberName.text = model.member_name
        cell.memberEmail.text = model.member_email
        //  cell.memberRole.text = values.member_privilege
        cell.memberRole.layer.borderWidth = 0.5
        cell.memberRole.layer.borderColor = UIColor.orange.cgColor
        cell.memberRole.layer.cornerRadius = 5
        if(model.member_privilege == "C"){
            cell.dotMenuBtn.isHidden = true
            let url = UserDefaults.standard.string(forKey: "userimg")
            cell.memberImage.sd_setImage(with: URL(string: url!), placeholderImage: UIImage(named: "about_app"))
              cell.memberRole.text = "Creator".localized()
        }
        else if(model.member_privilege == "M"){
            cell.dotMenuBtn.isHidden = false
            cell.memberRole.text = "Member".localized()
        }
        else{
            cell.dotMenuBtn.isHidden = false
             cell.memberRole.text = "Admin".localized()
        }
        cell.memberId.text = model.member_id
        //        let values = membersArray[indexPath.row]
//        cell.memberName.text = values.member_name
//        cell.memberEmail.text = values.member_email
//      //  cell.memberRole.text = values.member_privilege
//        if(values.member_privilege == "C"){
//            cell.dotMenuBtn.isHidden = true
//         //    cell.memberRole.text = "Creator"
//        }
//        else if(values.member_privilege == "M"){
//             cell.dotMenuBtn.isHidden = false
//            // cell.memberRole.text = "Member"
//        }
//        else{
//             cell.dotMenuBtn.isHidden = false
//           // cell.memberRole.text = "Member"
//        }
        return cell
    }
    //headercell
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "headercell") as! CustomHeaderCellTableViewCell
        headerCell.backgroundColor = UIColor.white
        let text = "Result Found"
        let text1 = "Total Members"
        switch (section) {
        case 0:
            if searchController.isActive && searchController.searchBar.text != "" {
                headerCell.membersLabel.text = "\(text.localized()) - \(filteredModels.count)";
            }
            else{
                 headerCell.membersLabel.text = "\(text1.localized()) - \(membersArray.count)";
            }
            
            
           
        //return sectionHeaderView
       
        default:
            headerCell.membersLabel.text = "";
        }
        
        return headerCell
    }
    func setupSearchController() {
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.barTintColor = UIColor(white: 0.9, alpha: 0.9)
        searchController.searchBar.placeholder = "Search by Member name or email".localized()
        searchController.hidesNavigationBarDuringPresentation = false
        
        memberListTable.tableHeaderView = searchController.searchBar
    }
    
    
    
    func filterRowsForSearchedText(_ searchText: String) {
        filteredModels = membersArray.filter({( model : listMembers) -> Bool in
            return model.member_name.lowercased().contains(searchText.lowercased())||model.member_email.lowercased().contains(searchText.lowercased())
        })
        memberListTable.reloadData()
    }
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        if user.userId == SBDMain.getCurrentUser()?.userId {
            if let index = self.channels.index(of: sender) {
                self.channels.remove(at: index)
            }
        }
    }
    @IBOutlet weak var memberListTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.memberListTable.tableFooterView = UIView()
        self.navigationItem.title = "Member List".localized()
        setupSearchController()
        //get userid to create group and send data to API
        userId = defaults.value(forKey: "User_ID") as! String
        //register cell
        memberListTable.register(UINib(nibName: "MemberListTableViewCells", bundle: nil), forCellReuseIdentifier: "cell")
        //call api
        viewMemberListApiCall()
        
        
        // Do any additional setup after loading the view.
    }
    //Api to remove admin role to selected group member
    func removeAdminToMemberApiCall(id:String){
        
        
        
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.removeAdminFromUser
        
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
            print(member)
        }
        paramString = String(format: "user_id=%@&group_id=%@&member_id=%@",userId,group_id,id)
        
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
                        self.view.makeToast("Admin dismissed Successfully".localized(),duration: 1.0)
                        self.membersArray.removeAll()
                        self.viewMemberListApiCall()
                        ANLoader.hide()
                        // self.view.hideAllToasts()
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
            
            
            
            
        }
        task.resume()
    }
    //Api to assign admin role to selected group member
    func assignAdminToMemberApiCall(id:String){
        //user_id(int), member_id(int), group_id(int)
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.assignAdminToUser
        
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
            print(member)
        }
        paramString = String(format: "user_id=%@&group_id=%@&member_id=%@",userId,group_id,id)
        
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
                        self.view.makeToast("Admin Assigned Successfully",duration: 1.0)
                        self.membersArray.removeAll()
                        self.viewMemberListApiCall()
                        ANLoader.hide()
                       // self.view.hideAllToasts()
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
            
            
            
            
        }
        task.resume()
    }
    //Api for remove member from group
    func removeMemberApiCall(id:String){

        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.".localized())
            }
        }
        else{
            
            ANLoader.showLoading("Loading", disableUI: true)
            
            let urlString = Constant.BASE_URL + Constant.removeUser
            
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
                print(member)
            }
            paramString = String(format: "user_id=%@&group_id=%@&member_id=%@",userId,group_id,id)
            
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
                                let fullName   = "\(self.group_name) - GRP-\(self.group_id)"
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
                                    let newname = "\(self.group_name) - GRP-\(self.group_id)"
                                    print(newname)
                                  
//                                        {
//                                            "user_ids": ["Philip", "Matthew", "Janna"]
//                                    }
                                //    let params:[String:AnyObject] = ["user_ids" : "563" as AnyObject]
                                    var array = [id]
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
                            self.view.makeToast("Member removed Successfully".localized(),duration: 1.0)
                            self.membersArray.removeAll()
                            self.viewMemberListApiCall()
                            ANLoader.hide()
                            // self.view.hideAllToasts()
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
                
                
                
                
            }
            task.resume()
        }
        
     
    }
    //Api call to display all members in group
    func viewMemberListApiCall(){
        //user_id(int), member_id(int), group_id(int)
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.viewUser
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        var paramString = ""
       
            
            paramString = String(format: "user_id=%@&group_id=%@&role=%@",userId,group_id,"1")
     
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
               let member_list_count = jsonObj?.value(forKey: "tot_member") as! Int
                if(member_list_count == 0){
                    self.view.makeToast("This group is not having any members".localized(),duration: 2.0)
                }
                else{
                    self.view.hideAllToasts()
                        let member_list = jsonObj?.value(forKey: "mem_list") as! NSArray
                        for values in member_list{
                        let email = (values as AnyObject).value(forKey: "email") as! String
                        let name = (values as AnyObject).value(forKey: "name") as! String
                        let privilege = (values as AnyObject).value(forKey: "privilege") as! String
                        let user_id = (values as AnyObject).value(forKey: "user_id") as! String
                        let memberList = listMembers(member_name: name, member_id: user_id, member_email: email, tot_member: member_list_count, member_privilege: privilege)
                        self.membersArray.append(memberList)
                        
                    }
                }
            }
            
            DispatchQueue.main.async{
                self.memberListTable.reloadData()
            }
            
            
        }
        task.resume()
    }
}
