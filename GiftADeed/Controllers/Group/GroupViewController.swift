//
//  GropuViewController.swift
//  GiftADeed
//
//  Created by Darshan on 2/14/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//Ref No : 2.3
import PopOverMenu
import UIKit
import ANLoader
import SDWebImage
import MMDrawController
import SendBirdSDK
import Localize_Swift
import ListPlaceholder

struct Group {
    let group_name : String
    let group_imageURL : String
    let group_id : String
}
struct Collaboration {
    let Collab_name : String
    let Collab_role : String
    let Collab_id : String
}
  var titles = ["Create Group".localized(),"Create Collaboration".localized(),"Collab Invites".localized()]
class GroupViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIAdaptivePresentationControllerDelegate {
    @IBOutlet weak var segmentbtns: UISegmentedControl!
    var segmentBtn = ""
    @IBAction func segmentBtnPress(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            self.groupListArray.removeAll()
            self.collabListArray.removeAll()
            self.grupListApiCall()
            let status = UserDefaults.standard.bool(forKey: "creategroup")
            segmentBtn = "group"
            if(groupListArray.count > 0 && status == false){
                messageLblText.isHidden = true
                createBtn.isHidden = true
                grupListView.isHidden = false
                
            }else{
                messageLblText.isHidden = false
                createBtn.isHidden = false
                messageLblText.text = "No groups found. Do you want to create one?".localized()
                createBtn.setTitle("Create group".localized(), for: .normal)
                grupListView.isHidden = true
            }
        }
        else{
           
            //show collaborations list
           
             segmentBtn = "collab"
            self.groupListArray.removeAll()
            //reload data of collaboration
           // self.grupListView.reloadData()
            //if collaboration count is equal to 0 then show create collaboration button and label
            // otherwise show collaboration list
               self.CollaborationListApiCall()
            if(collabListArray.count > 0){
                messageLblText.isHidden = true
                createBtn.isHidden = true
                grupListView.isHidden = false
                
            }else{
                messageLblText.isHidden = false
                createBtn.isHidden = false
                messageLblText.text = "No collaboration found. Do you want to create one?".localized()
                createBtn.setTitle("Create collaboration".localized(), for: .normal)
                grupListView.isHidden = true
            }
            self.grupListView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(groupListArray.count)
    
        if(self.groupListArray.count == 0){
            self.messageLblText.isHidden = false
            self.createBtn.isHidden  = false
            return 0
        }
        else{
            self.messageLblText.isHidden = true
            self.createBtn.isHidden  = true
            if(segmentBtn == "group"){
                let status = UserDefaults.standard.bool(forKey: "creategroup")
                if(groupListArray.count > 0 && status == false){
                    messageLblText.isHidden = true
                    createBtn.isHidden = true
                    grupListView.isHidden = false
                }else{
                    messageLblText.isHidden = false
                    createBtn.isHidden = false
                    grupListView.isHidden = true
                }
                return groupListArray.count
            }else{
                if(collabListArray.count > 0){
                    messageLblText.isHidden = true
                    createBtn.isHidden = true
                    grupListView.isHidden = false
                }else{
                    messageLblText.isHidden = false
                    createBtn.isHidden = false
                    grupListView.isHidden = true
                }
                print(collabListArray.count)
                return collabListArray.count
            }
        }
       
    
       
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
//        var numOfSections: Int = 0
//        if groupListArray.count > 0
//        {
//            tableView.separatorStyle = .singleLine
//            numOfSections            = 1
//            tableView.backgroundView = nil
//        }
//        else
//        {
//            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//            noDataLabel.text          = "No data available"
//            noDataLabel.textColor     = UIColor.black
//            noDataLabel.textAlignment = .center
//            tableView.backgroundView  = noDataLabel
//            tableView.separatorStyle  = .none
//        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GroupTableViewCell
        if(segmentBtn == "group"){
            cell.collabName.isHidden = true
              cell.groupImage.isHidden = false
            cell.groupname.isHidden = false
        let values = groupListArray[indexPath.row]
        let img = values.group_imageURL
        cell.groupname.text = values.group_name
        let imgURL = String(format: "%@%@", Constant.BASE_URL , img)
        print(imgURL)
        cell.groupImage.layer.borderColor = UIColor.gray.cgColor
        cell.groupImage.layer.borderWidth = 0.5
        cell.groupImage.sd_setShowActivityIndicatorView(true)
        cell.groupImage.sd_setIndicatorStyle(.gray)
        if(imgURL.isEmpty){
              cell.groupImage.contentMode = .scaleAspectFit
        }
        else{
            cell.groupImage.contentMode = .scaleToFill
        }
        cell.groupImage!.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "ic_launcher-1"))
        }
        else{
            let values = collabListArray[indexPath.row]
            print(values.Collab_name)
              cell.collabName.isHidden = false
            cell.groupImage.isHidden = true
            cell.groupname.isHidden = true
            cell.collabName.text = values.Collab_name
        }
        return cell
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(segmentBtn == "group"){
            return 87
        }
        else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(segmentBtn == "group"){
        // Get Cell details
        let values = groupListArray[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as! GroupDetailViewController
        viewController.group_id = values.group_id
        viewController.group_img_url = values.group_imageURL
        viewController.groupTitle = values.group_name
        self.navigationController!.pushViewController(viewController, animated: true)
        }
        else{
            // Get Cell details
            let values = collabListArray[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "CollaborationDetailViewController") as! CollaborationDetailViewController
            viewController.collab_id = values.Collab_id
            viewController.collab_role = values.Collab_role
            viewController.collab_name = values.Collab_name
            self.navigationController!.pushViewController(viewController, animated: true)
        }
    }
   
    var refreshControl = UIRefreshControl()
    var userId = ""
    var name = ""
    var groupListArray = [Group]()
    var collabListArray = [Collaboration]()
    @IBOutlet weak var grupListView: UITableView!
    @IBOutlet weak var messageLblText: UILabel!
    @IBOutlet weak var createBtn: UIButton!
    override func viewDidAppear(_ animated: Bool) {
               // hide all start time
                messageLblText.isHidden = true
                createBtn.isHidden = true
                grupListView.isHidden = true
        let status = UserDefaults.standard.bool(forKey: "creategroup")
        if(  self.segmentbtns.selectedSegmentIndex == 0){
            if(groupListArray.count > 0 && status == false){
                messageLblText.isHidden = true
                createBtn.isHidden = true
                grupListView.isHidden = false
                
            }else{
                messageLblText.isHidden = false
                createBtn.isHidden = false
                messageLblText.text = "No groups found. Do you want to create one?".localized()
                createBtn.setTitle("Create group".localized(), for: .normal)
                grupListView.isHidden = true
            }
        }
        else{
        
        if(collabListArray.count > 0 && status == false){
            messageLblText.isHidden = true
            createBtn.isHidden = true
            grupListView.isHidden = false
            
        }else{
            messageLblText.isHidden = false
            createBtn.isHidden = false
            messageLblText.text = "No Collaborations found. Do you want to create one?".localized()
            createBtn.setTitle("Create Collaboration".localized(), for: .normal)
            grupListView.isHidden = true
        }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
          // NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("collaboration"), object: nil)
       //    NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification1(notification:)), name: Notification.Name("fromcollab"), object: nil)
      //  self.CollaborationListApiCall()
      //  self.grupListView.reloadData()
    }
  
    @objc func methodOfReceivedNotification(notification: Notification) {
        self.collabListArray.removeAll()
        self.groupListArray.removeAll()
        viewDidLoad()
        
        self.segmentbtns.selectedSegmentIndex = 0
        
     //   self.CollaborationListApiCall()
        if(collabListArray.count > 0){
            messageLblText.isHidden = true
            createBtn.isHidden = true
            grupListView.isHidden = false
            
        }else{
            messageLblText.isHidden = false
            createBtn.isHidden = false
            messageLblText.text = "No collaboration found. Do you want to create one?".localized()
            createBtn.setTitle("Create collaboration".localized(), for: .normal)
            grupListView.isHidden = true
        }
       //   NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfCollabReceivedNotification(notification:)), name: Notification.Name("collabCreate"), object: nil)
    }
    @objc func methodOfCollabReceivedNotification(notification: Notification) {
//        self.CollaborationListApiCall()
//         self.segmentbtns.selectedSegmentIndex = 1
//
    }
    @objc func refresh() {
        // Code to refresh table view
        groupListArray.removeAll()
        grupListApiCall()
    }
    func setText(){
       // self.messageLblText.text = "No groups found. Do you want to create one?".localized()
        self.segmentbtns.setTitle("GROUPS".localized(), forSegmentAt: 0)
        self.segmentbtns.setTitle("COLLABORATIONS".localized(), forSegmentAt: 1)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Groups".localized()
        //pull to refresh
        setText()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        grupListView.addSubview(refreshControl) // not required when using UITableViewController
        //register cell
        grupListView.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        //get userid to show group list
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        segmentBtn = "group"
        createBtn.layer.cornerRadius = 5
        createBtn.layer.borderWidth = 0.5
        createBtn.layer.borderColor = UIColor.gray.cgColor
        //Call view Group API and save data in array if array count is > 0 then isplay table otherwise display messagelbl with create group button .
        //on first launch set table hidden
        grupListView.isHidden = true
        grupListApiCall()
        print(groupListArray.count)
        //tableview cell seprator
        self.grupListView.tableFooterView = UIView()
        grupListView.separatorColor = UIColor.black
        grupListView.layoutMargins = UIEdgeInsets.zero
        grupListView.separatorInset = UIEdgeInsets.zero
        //userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        // hide all start time
        messageLblText.isHidden = true
        createBtn.isHidden = true
        grupListView.isHidden = true
        let status = UserDefaults.standard.bool(forKey: "creategroup")
        if(  self.segmentbtns.selectedSegmentIndex == 0){
            if(groupListArray.count > 0 && status == false){
                messageLblText.isHidden = true
                createBtn.isHidden = true
                grupListView.isHidden = false
                
            }else{
                messageLblText.isHidden = false
                createBtn.isHidden = false
                messageLblText.text = "No groups found. Do you want to create one?".localized()
                createBtn.setTitle("Create group".localized(), for: .normal)
                grupListView.isHidden = true
            }
        }
        else{
            
            if(collabListArray.count > 0 && status == false){
                messageLblText.isHidden = true
                createBtn.isHidden = true
                grupListView.isHidden = false
                
            }else{
                messageLblText.isHidden = false
                createBtn.isHidden = false
                messageLblText.text = "No Collaborations found. Do you want to create one?".localized()
                createBtn.setTitle("Create Collaboration".localized(), for: .normal)
                grupListView.isHidden = true
            }
        }
        name = UserDefaults.standard.value(forKey: "Fname") as! String
        // Do any additional setup after loading the view.
        // self.connect()
    }
    @objc func removeLoader()
    {
        self.grupListView.hideLoader()
    }
    func connect() {
        let trimmedUserId: String = (self.userId.trimmingCharacters(in: NSCharacterSet.whitespaces))
        let trimmedNickname: String = (self.name.trimmingCharacters(in: NSCharacterSet.whitespaces))
        guard trimmedUserId.count > 0 && trimmedNickname.count > 0 else {
            return
        }
//self.userIdTextField.isEnabled = false
//self.nicknameTextField.isEnabled = false
//self.indicatorView.startAnimating()
        ConnectionManager.login(userId: trimmedUserId, nickname: trimmedNickname) { (user, error) in
            DispatchQueue.main.async {
//                self.userIdTextField.isEnabled = true
//                self.nicknameTextField.isEnabled = true
//                self.indicatorView.stopAnimating()
            }
            guard error == nil else {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                return
            }
            DispatchQueue.main.async {
                let vc: MenuViewController = MenuViewController()
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
   
    @IBAction func createGroupChatBtnPress(_ sender: UIBarButtonItem) {
        self.connect()
    }
    
    @IBAction func navBarBtnPress(_ sender: UIBarButtonItem) {
       // let titles = ["Create Group".localized(),"Create Collaboration".localized(),"Collab Invites".localized()]
        let popOverViewController = PopOverViewController.instantiate()
        popOverViewController.setTitles(titles)
        popOverViewController.popoverPresentationController?.barButtonItem = sender
        popOverViewController.preferredContentSize = CGSize(width: 200, height:150)
        popOverViewController.presentationController?.delegate = self
        popOverViewController.completionHandler = { selectRow in
            switch (selectRow) {
            case 0:
                let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as? CreateGroupViewController
                // memberViewController!.group_id = self.group_id
                self.navigationController?.pushViewController(memberViewController!, animated: true)
                print("ZERO")
                break
            case 1:
                let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateCollaborationViewController") as? CreateCollaborationViewController
                // memberViewController!.group_id = self.group_id
                self.navigationController?.pushViewController(memberViewController!, animated: true)
                break
            case 2:
                let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CollabInvitesListTableViewController") as? CollabInvitesListTableViewController
              //   memberViewController!.group_id = self.c
                self.navigationController?.pushViewController(memberViewController!, animated: true)
                break
            default:
                //CollabInvitesListTableViewController
                break
            }
            
        };
        present(popOverViewController, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    @IBAction func menuBtnPress(_ sender: UIBarButtonItem) {
        if let drawer = self.drawer() ,
            let manager = drawer.getManager(direction: .left){
            let value = !manager.isShow
             drawer.isShowMask = true
            drawer.showLeftSlider(isShow: value)
        }
    }
    @IBAction func createGroupBtnPress(_ sender: UIButton) {
        if (segmentBtn == "group"){
            //redirect to create club
//            let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as? CreateGroupViewController
//            // memberViewController!.group_id = self.group_id
//            self.navigationController?.pushViewController(memberViewController!, animated: true)
        }
        else{
            //redirect to create collaboration
            let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateCollaborationViewController") as? CreateCollaborationViewController
            // memberViewController!.group_id = self.group_id
            self.navigationController?.pushViewController(memberViewController!, animated: true)
        }
    }
    func grupListApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.showGroupList
        
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                for values in jsonObj!{
                    let group_id = (values as AnyObject).value(forKey: "group_id")
                    let group_logo = (values as AnyObject).value(forKey: "group_logo")
                    let group_name = (values as AnyObject).value(forKey: "group_name")
                    let groups = Group(group_name: group_name as! String, group_imageURL: group_logo as! String, group_id: group_id as! String)
                    print(groups)
                    self.groupListArray.append(groups)
                }
                
            }
            DispatchQueue.main.async{
                print(self.groupListArray)
                self.refreshControl.endRefreshing()
                self.grupListView.reloadData()
              //  self.grupListView.showLoader()
              //  Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GroupViewController.removeLoader), userInfo: nil, repeats: false)
            }
        }
        
        task.resume()
    }
    //Collaboration list
    func CollaborationListApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.users_collaboration_list
        
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
                print(jsonObj!)
                let status = jsonObj?.value(forKey: "status") as! Int
                if(status == 1){
                    let users_collaboration_list = jsonObj?.value(forKey: "users_collaboration_list") as! NSArray
                    for users in users_collaboration_list{
                    let collaboration_id = (users as AnyObject).value(forKey: "collaboration_id") as! String
                    let collaboration_name = (users as AnyObject).value(forKey: "collaboration_name") as! String
                    let user_role = (users as AnyObject).value(forKey: "user_role") as! String
                    let collab = Collaboration(Collab_name: collaboration_name, Collab_role: user_role, Collab_id: collaboration_id)
                         self.collabListArray.append(collab)
                    }
                   
                }
            }
            DispatchQueue.main.async{
                    print(self.collabListArray)
                    self.refreshControl.endRefreshing()
                    self.grupListView.reloadData()
                
            }
        }
        
        task.resume()
    }
}
