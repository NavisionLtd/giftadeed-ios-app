//
//  CollabInvitesListTableViewController.swift
//  GiftADeed
//
//  Created by Darshan on 5/31/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import SendBirdSDK
import Localize_Swift

struct collabReq {
    let name : String
    let detail : String
    let Started_on : String
    let id : String
    let creatorid : String
}
class CollabInvitesListTableViewController: UITableViewController,CellReqListSubclassDelegate {

    func acceptButtonTapped(id: String, name: String, creator_id: String) {
        //accept api
        collabReqDecideApiCall(collab_id: id, collab_name: name, status: "A",creatorId: creator_id)
    }
    
    func rejectButtonTapped(id: String, name: String, creator_id: String) {
        //reject api
        collabReqDecideApiCall(collab_id: id, collab_name: name, status: "R",creatorId: creator_id)
    }
    //sendbird
    fileprivate var channels: [SBDGroupChannel] = []
    fileprivate var myGroupChannelListQuery: SBDGroupChannelListQuery?
var collabReqListArray = [collabReq]()
    var userId = ""
    
    @IBOutlet var collabReqList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:" ", style:.plain, target:nil, action:nil)
        self.navigationItem.title = "Collab Invites".localized()
        //get userid to show group list
        
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        collabReqListApiCall()
        
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
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var numOfSections: Int = 0
        if self.collabReqListArray.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No records found"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return collabReqListArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CollabRequestListTableViewCell
        let value = collabReqListArray[indexPath.row]
        cell.name.text = value.name
        cell.descriptions.text = value.detail
        cell.date.text = value.Started_on
        cell.idlbl.text = value.id
        cell.delegate = self
        // Configure the cell...

        return cell
    }
    func collabReqDecideApiCall(collab_id : String,collab_name : String,status :String,creatorId :String){
        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.".localized())
            }
        }
        else{
            var linkUrl = ""
            if(status == "A"){
                linkUrl = "accept"
            }
            else{
                linkUrl = "decline"
            }
            ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
            let urlString = Constant.BASE_URL + Constant.edit_collaboration_request_status
            let url:NSURL = NSURL(string: urlString)!
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            let charset = NSMutableCharacterSet.alphanumeric()
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            let paramString = String(format: "user_id=%@&collaboration_id=%@&invitation_status=%@",userId,collab_id,status)
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
                    print(jsonObj)
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        let success_message = jsonObj?.value(forKey: "success_message") as! String
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
                                let fullName   = "\(collab_name) - CLB\(collab_id)"
                                print("\(channel.name)\(fullName)")
                                if(channel.name == fullName){
                                    print("chanel is present")
                                    self.channels.removeAll()
                                    self.channels.append(channel)
                                    print(self.channels)
                                    print("\(channel.name)")
                                    print(channel.channelUrl)
                                    let session = URLSession.shared
                                    
                                    let url = "https://api-2B2DA376-91B5-4604-9279-C0533F130126.sendbird.com/v3/group_channels/\(channel.channelUrl)/\(linkUrl)"
                                    print(url)
                                    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                                    request.addValue("cf709ee2fa69a3823f90bdc98647c0d2e850d3cf", forHTTPHeaderField: "Api-Token")
                                    request.httpMethod = "PUT"
                                    let newname = "\(collab_name) - CLB\(collab_id)"
                                    print(newname)
                                
                                      let params:[String:AnyObject] = ["user_ids" : creatorId as AnyObject]
                                
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
                            
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.view.makeToast(success_message.localized())
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else  if(status == 0){
                        DispatchQueue.main.async{
                            let error_message = jsonObj?.value(forKey: "error_message") as! String
                            self.view.makeToast(error_message.localized())
                        }
                    }
                }
                DispatchQueue.main.async{
                    
                }
            }
            
            task.resume()
        }
       
    }
    func collabReqListApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.collaboration_request_list
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@",userId)
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
                print(jsonObj)
                let status = jsonObj?.value(forKey: "status") as! Int
                if(status == 1){
                     let request_list = jsonObj?.value(forKey: "request_list") as! NSArray
                    for item in request_list{
                        let collaboration_description = (item as AnyObject).value(forKey: "collaboration_description") as! String
                        let collaboration_id = (item as AnyObject).value(forKey: "collaboration_id") as! String
                        let creator_id = (item as AnyObject).value(forKey: "creator_id") as! String
                        let collaboration_name = (item as AnyObject).value(forKey: "collaboration_name") as! String
                        let collaboration_start_date = (item as AnyObject).value(forKey: "collaboration_start_date") as! String
                        let invitation_status = (item as AnyObject).value(forKey: "invitation_status") as! String
                        let collabReqList = collabReq(name: collaboration_name, detail: collaboration_description, Started_on: collaboration_start_date, id: collaboration_id, creatorid: creator_id)
                        self.collabReqListArray.append(collabReqList)
                    }
                    DispatchQueue.main.async{
                        print(self.collabReqListArray)
                       // self.refreshControl.endRefreshing()
                        self.collabReqList.reloadData()
                    }
                }
                else  if(status == 0){
               let error_message = jsonObj?.value(forKey: "error_message") as! String
                    self.view.makeToast(error_message.localized())
                }
            }
            DispatchQueue.main.async{
               
            }
        }
        
        task.resume()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
