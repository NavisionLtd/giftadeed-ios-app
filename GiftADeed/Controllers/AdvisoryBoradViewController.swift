//
//  AdvisoryBoradViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 09/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader

class AdvisoryBoradViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet  var outletNoRecord: UILabel!
    @IBOutlet  var outletTableView: UITableView!
    var advisoryBoradArr = NSMutableArray()
    let defaults = UserDefaults.standard
    var userId = ""
    
    var twiterURL = ""
    var googlePlusURL = ""
    var facebookURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        outletTableView.delegate = self
        outletTableView.dataSource = self
        
        userId = defaults.value(forKey: "User_ID") as! String
        self.downloadData()
    }

    @IBAction func menuBarAction(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            GlobalClass.sharedInstance.openMenu();
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return advisoryBoradArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? AdvisoryBoardTableViewCell!
        cell?!.layer.cornerRadius=2
        
        let item = self.advisoryBoradArr[indexPath.section] as? NSDictionary

        let imgUrl = String(format: "%@%@", Constant.BASE_URL ,(item as AnyObject).value(forKey:"imgUrl") as! String)
        
        cell?!.outletImgUrl.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "default"))
        cell?!.outletName.text = String(format: "%@", (item as AnyObject).value(forKey:"name") as! String)
        cell?!.outletDesig.text = String(format: "%@", (item as AnyObject).value(forKey:"desig") as! String)
        cell?!.outletDesc.text = String(format: "%@", (item as AnyObject).value(forKey:"desc") as! String)

        cell?!.twiterAction.tag = indexPath.section
        cell?!.twiterAction.addTarget(self, action: #selector(twiter(_:)), for: .touchDown)
        
        cell?!.googlePlusAction.tag = indexPath.section
        cell?!.googlePlusAction.addTarget(self, action: #selector(googlePlus(_:)), for: .touchDown)
        
        cell?!.facebookAction.tag = indexPath.section
        cell?!.facebookAction.addTarget(self, action: #selector(facebook(_:)), for: .touchDown)
        return cell!!
    }
    
    @objc func twiter(_ sender:UIButton) {
        
        let item = self.advisoryBoradArr[sender.tag] as? NSDictionary
        let urls = String(format: "%@", (item as AnyObject).value(forKey:"socialLinks") as! String)
        let URLarray = urls.components(separatedBy: ",")
        
        for i in 0..<URLarray.count {
            
            if URLarray[i].lowercased().range(of:"twitter") != nil {
                
                self.twiterURL = URLarray[i]
                UIApplication.shared.open(URL(string : self.twiterURL )!, options: [:], completionHandler:nil)
            }
            else{
                
                
            }
        }
    }
    
    @objc func googlePlus(_ sender:UIButton) {
        
        let item = self.advisoryBoradArr[sender.tag] as? NSDictionary
        let urls = String(format: "%@", (item as AnyObject).value(forKey:"socialLinks") as! String)
        let URLarray = urls.components(separatedBy: ",")
        
        for i in 0..<URLarray.count {
            
            if URLarray[i].lowercased().range(of:"google") != nil {
                
                self.googlePlusURL = URLarray[i]
                UIApplication.shared.open(URL(string : self.googlePlusURL )!, options: [:], completionHandler:nil)
            }
            else{
                
                
            }
        }
    }
    
    @objc func facebook(_ sender:UIButton) {
        
        let item = self.advisoryBoradArr[sender.tag] as? NSDictionary
        let urls = String(format: "%@", (item as AnyObject).value(forKey:"socialLinks") as! String)
        let URLarray = urls.components(separatedBy: ",")
        
        for i in 0..<URLarray.count {
            
            if URLarray[i].lowercased().range(of:"facebook") != nil {
                
                self.facebookURL = URLarray[i]
                UIApplication.shared.open(URL(string : self.facebookURL )!, options: [:], completionHandler:nil)
            }
            else{
                
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 5
    }
    
    func downloadData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.advisory_board
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "User_ID=%@", userId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            ANLoader.hide()
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast(Validation.ERROR)
                
                self.outletNoRecord.isHidden = false
                self.outletNoRecord.text = "Some error occured"
                print("error")
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        GlobalClass.sharedInstance.blockStatus = true
                    }
                    return
                }
                
                if let taggedlist = jsonObj!.value(forKey: "advisory") as? NSArray {
                    
                    for item in taggedlist {
                        
                        let taggedItem = item as? NSDictionary
                        
                        do {
                            
                            try self.advisoryBoradArr.add(taggedItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }
                    
                    if taggedlist.count == 0{
                        
                        DispatchQueue.main.async{
                            
                            self.outletNoRecord.isHidden = false
                        }
                    }
                    else{
                        
                        DispatchQueue.main.async{
                            
                            self.outletNoRecord.isHidden = true
                            self.updateUI()
                        }
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func updateUI() {
        
        outletTableView.reloadData()
    }
    
}
