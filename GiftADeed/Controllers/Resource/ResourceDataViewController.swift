//
//  ResourceDataViewController.swift
//  GiftADeed
//
//  Created by Darshan on 4/2/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import SDWebImage

class ResourceDataViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
   
        return cell
    }
    @IBOutlet weak var resourceDataTbl: UITableView!
   
 
    override func viewWillAppear(_ animated: Bool) {
      OwnedgrupListApiCall()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        resourceDataTbl.layer.borderWidth = 0.5
        OwnedgrupListApiCall()
        showAnimate()
   
    }
    func OwnedgrupListApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.owned_groups
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@","494")
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                print(jsonObj)
//                for values in jsonObj!{
//                    let group_id = (values as AnyObject).value(forKey: "group_id")
//                    let group_name = (values as AnyObject).value(forKey: "group_name")
//                    let groups = ownedGroup(grp_name: group_name as! String, grp_id:group_id as! String )
//                    print(groups)
//                    self.ownedGroupListArray.append(groups)
//                }
                
            }
            DispatchQueue.main.async{
             //   print(self.ownedGroupListArray)
            }
        }
        
        task.resume()
    }

    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
   
}
