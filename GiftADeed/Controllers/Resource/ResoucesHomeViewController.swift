//
//  ResoucesHomeViewController.swift
//  GiftADeed
//
//  Created by Darshan on 4/2/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//
import Localize_Swift
import UIKit
import ANLoader
extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }
    }
}
struct resource {
    let resource_id : String
    let resource_name : String
    let resource_createdby : String
    let resource_date : String
    let resource_category : String
}
class ResoucesHomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resourceListArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if self.resourceListArray.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No records found".localized()
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Resources".localized()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResourceListTableViewCell
        let values = resourceListArray[indexPath.row]
        let texts = "Resource Name :"
        let string = NSMutableAttributedString(string: "\(texts.localized())\(values.resource_createdby)")
        string.setColorForText("Resource Name ", with: #colorLiteral(red: 1, green: 0.4863353968, blue: 0, alpha: 1))
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
         cell.name.attributedText = string
        let text = "Category :"
        let text1 = "Created by :"
        let text2 = "Created on :"
       // cell.name.text = ("Resource Name :\(values.resource_createdby)")
         cell.category.text = ("\(text.localized())\(values.resource_category)")
         cell.createdby.text = ("\(text1.localized())\(values.resource_name)")
         cell.createdat.text = ("\(text1.localized())\(values.resource_date)")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Cell details
        let values = resourceListArray[indexPath.row]
        //        let indexPath = grupListView.indexPathForSelectedRow
        //        let currentCell = grupListView.cellForRow(at: indexPath!) as! GroupTableViewCell!;
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ResourceDetailViewController") as! ResourceDetailViewController
        viewController.resource_id = values.resource_id
       
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 140.0;//Choose your custom row height
    }
    @IBOutlet weak var resourceTbl: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!

    var refreshControl = UIRefreshControl()
    var userId = ""
    var resourceListArray = [resource]()
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(ResoucesHomeViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("resourceDeleted"), object: nil)
        super.viewDidLoad()
          self.navigationItem.title = "Resources".localized()
         self.resourceTbl.tableFooterView = UIView()
        //register cell
        resourceTbl.register(UINib(nibName: "ResourceListTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        resourceTbl.rowHeight = UITableViewAutomaticDimension
        resourceTbl.estimatedRowHeight = 173
        //pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        resourceTbl.addSubview(refreshControl) // not required when using UITableViewController
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        self.resourceListApiCall()
        self.resourceTbl.reloadData()
//Here all resource list will displayed with edit and delete button
        // Do any additional setup after loading the view.
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        // Take Action on Notification
         resourceListArray.removeAll()
         resourceListApiCall()
    }
    @objc func refresh() {
        // Code to refresh table view
        resourceListArray.removeAll()
        resourceListApiCall()
        
    }
    @IBAction func menuBtnPress(_ sender: UIBarButtonItem) {
        if let drawer = self.drawer() ,
            let manager = drawer.getManager(direction: .left){
            let value = !manager.isShow
             drawer.isShowMask = true
            drawer.showLeftSlider(isShow: value)
        }
    }
    
    @IBAction func createResourceBtnPress(_ sender: UIBarButtonItem) {
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "CreateResourceViewController") as? CreateResourceViewController
        self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
    }
   //user_resource
    func resourceListApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.user_resource
        
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
                    self.view.makeToast(Validation.ERROR)
                }
                return
            }
            //[{"id","resource_name","group_name","created_date","need_name"}]
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                for values in jsonObj!{
                    let id = (values as AnyObject).value(forKey: "id") as! String
                    let group_name = (values as AnyObject).value(forKey: "group_name") as! String
                    let resource_name = (values as AnyObject).value(forKey: "resource_name") as! String
                    let created_date = (values as AnyObject).value(forKey: "created_date") as! String
                    let need_name = (values as AnyObject).value(forKey: "need_name") as? String
                    let ctm_category = (values as AnyObject).value(forKey: "custom_need_name") as? String
                    let res = resource(resource_id: id, resource_name: group_name, resource_createdby: resource_name, resource_date: created_date, resource_category: need_name ?? "N?A")
                    self.resourceListArray.append(res)
                }
            }
            DispatchQueue.main.async{
                print(self.resourceListArray)
                self.refreshControl.endRefreshing()
                self.resourceTbl.reloadData()
            }
        }
        task.resume()
    }
}
