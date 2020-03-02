//
//  NumberPickerViewController.swift
//  EzPopup_Example
//
//  Created by Huy Nguyen on 6/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol NumberPickerViewControllerDelegate: class {
    func numberPickerViewController(sender: NumberPickerViewController, didSelectNumber number: Int)
}

class NumberPickerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var rate_id = ""
    var replyarry = NSMutableArray()
    weak var delegate: NumberPickerViewControllerDelegate?
    
    static func instantiate() -> NumberPickerViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(NumberPickerViewController.self)") as? NumberPickerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        tableView.separatorInset = UIEdgeInsets.zero
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "sendid"), object: nil)
       
    }
    // handle notification
    func showSpinningWheel(_ notification: NSNotification) {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["id"] as? String{
                // do something with your image
                print(id)
                rate_id = id
                 replyApi()
            }
        }
    }
    func replyApi(){
       
            let urlString = Constants.BASE_URL + Constants.showClubCommentReply
            let url:NSURL = NSURL(string: urlString)!
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            
            let paramString = String(format: "rate_id=%@",rate_id)
            print(paramString)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request as URLRequest) {
                (data, response, error) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                }
                guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                    DispatchQueue.main.async{
                        self.view.makeToast(Validation.ERROR)
                    }
                    return
                }
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    print(jsonObj as Any)
                    let ClubRate = jsonObj!.value(forKey: "ClubRate") as! NSArray
                    print(ClubRate)
                    for item in ClubRate{
                    let reply = (item as AnyObject).value(forKey: "reply") as! String
                        if(reply == ""){
                            
                        }
                        else{
                              self.replyarry.add(reply)
                        }
                       DispatchQueue.main.async{
                        self.tableView.reloadData()
                        }
                    }
                }
            }
                        task.resume()
            
        }
    

}

extension NumberPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyarry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = replyarry[indexPath.row] as! String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.numberPickerViewController(sender: self, didSelectNumber: indexPath.row)
    }
}
