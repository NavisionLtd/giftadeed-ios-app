//
//  GroupInfoViewController.swift
//  GiftADeed
//
//  Created by Darshan on 2/20/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit
import PopOverMenu
import EzPopup
import ANLoader
import  Localize_Swift
class GroupInfoViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.membersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberListTableViewCells
          let model: listMembers
          model = membersArray[indexPath.row]
        cell.memberName.text = model.member_name
        cell.memberEmail.text = model.member_email
        //  cell.memberRole.text = values.member_privilege
        cell.memberRole.layer.borderWidth = 0.5
        cell.memberRole.layer.borderColor = UIColor.orange.cgColor
        cell.memberRole.layer.cornerRadius = 5
        cell.dotMenuBtn.isHidden = true
        if(model.member_privilege == "C"){
            cell.dotMenuBtn.isHidden = true
            cell.memberRole.text = "Creator".localized()
        }
        else if(model.member_privilege == "M"){
            cell.dotMenuBtn.isHidden = true
            cell.memberRole.text = "Member".localized()
        }
        else{
            cell.dotMenuBtn.isHidden = true
            cell.memberRole.text = "Admin".localized()
        }
        return cell
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
                self.groupInfoTable.reloadData()
            }
            
            
        }
        task.resume()
    }
    func groupInfoApiCall()
    {
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.groupInfo
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@&group_id=%@",userId,group_id)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
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
                for values in jsonObj!{
                    let admin_ids = (values as AnyObject).value(forKey: "admin_ids") as! String
                    let create_date = (values as AnyObject).value(forKey: "create_date") as! String
                    let creator_id = (values as AnyObject).value(forKey: "creator_id") as! String
                    let creator_name = (values as AnyObject).value(forKey: "creator_name") as! String
                    let description = (values as AnyObject).value(forKey: "description") as! String
                    let group_logo = (values as AnyObject).value(forKey: "group_logo") as! String
                    let grp_name = (values as AnyObject).value(forKey: "grp_name") as! String
                    let imgURL = String(format: "%@%@", Constant.BASE_URL , group_logo)
                    print(imgURL)
                      DispatchQueue.main.async{
                        self.groupName.text = ("Group name : \(grp_name) & Total Members :\(self.membersArray.count)")
                    self.groupDescription.text = ("Description : \(description)")
                    self.groupCreator.text = ("Created by : \(creator_name) & Created on \(create_date)")
                    }
                    if(group_logo == ""){
                        self.imageView.image = UIImage(named: "ic_launcher-1")
                         DispatchQueue.main.async{
                            self.imageView.contentMode = .scaleAspectFill}
                        self.imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: 1).enable()
                        self.headerImageView = self.imageView
                        self.groupInfoTable.parallaxHeader.view = self.imageView
                        self.groupInfoTable.parallaxHeader.height = 200
                        self.groupInfoTable.parallaxHeader.minimumHeight = 40
                        self.groupInfoTable.parallaxHeader.mode = .centerFill
                        
                        self.groupInfoTable.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
                            //update alpha of blur view on top of image view
                            parallaxHeader.view.blurView.alpha = 1 - parallaxHeader.progress
                        }
                        
                    }else{
                        self.imageView.sd_setImage(with: URL(string: imgURL), placeholderImage:nil)
                        DispatchQueue.main.async{
                            self.imageView.contentMode = .scaleAspectFill
                        }
                        
                        self.imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: 1).enable()
                        self.headerImageView = self.imageView
                        self.groupInfoTable.parallaxHeader.view = self.imageView
                        self.groupInfoTable.parallaxHeader.height = 200
                        self.groupInfoTable.parallaxHeader.minimumHeight = 40
                        self.groupInfoTable.parallaxHeader.mode = .centerFill
                        
                        self.groupInfoTable.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
                            //update alpha of blur view on top of image view
                            parallaxHeader.view.blurView.alpha = 1 - parallaxHeader.progress
                        }
                    }
                  
                }
               
            }
            
            DispatchQueue.main.async{
            }
            
            
        }
        task.resume()
    }
  var membersArray = [listMembers]()
    @IBOutlet weak var groupInfoTable: UITableView!
    var group_id = ""
    var userId = ""
    let imageView = UIImageView()
    weak var headerImageView: UIView?
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalTextView.layer.borderWidth = 1
        additionalTextView.layer.borderColor = UIColor.orange.cgColor
        self.navigationItem.title = "Group info".localized()
        groupInfoApiCall()
        viewMemberListApiCall()
        //get userid to create group and send data to API
        userId = defaults.value(forKey: "User_ID") as! String
        //register cell
        groupInfoTable.register(UINib(nibName: "MemberListTableViewCells", bundle: nil), forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var additionalTextView: UIView!
    @IBOutlet weak var groupCreator: UILabel!
    @IBOutlet weak var groupDescription: UILabel!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
