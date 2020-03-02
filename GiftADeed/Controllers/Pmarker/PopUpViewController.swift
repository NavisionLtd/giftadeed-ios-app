//
//  PopUpViewController.swift
//  PopUp
//
//  Created by Andrew Seeley on 6/06/2016.
//  Copyright © 2016 Seemu. All rights reserved.
//

import UIKit
import ANLoader


class PopUpViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parraylist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as! pmarkerTableViewCell
         let values = self.parraylist[indexPath.row]
        let img = ("\(Constant.BASE_URL)/\(values.icon_path)")
        cell.imgView!.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: "default"))
        cell.name?.text = ("\(values.need_name)-\(values.tag_id)")
        cell.subType?.text = values.sub_types
        return cell
    }
    
    @IBAction func tagADeedBtnPress(_ sender: UIButton) {
        let markerAddress = UserDefaults.standard.string(forKey: "markerAddress")
        let markerGeo  = UserDefaults.standard.string(forKey: "markerGeo")
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TagADeedsViewController") as! TagADeedsViewController
        viewController.addressString = markerAddress!
        print(markerGeo!)
        viewController.geoPoint = markerGeo!
        viewController.data = "P"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var plistTbl: UITableView!
    let defaults = UserDefaults.standard
    var userId = ""
    var snipetId = ""
   var geo = ""
    var parraylist = [pDeedList]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(geo)
        self.userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.downloadPListMarker(geo: self.geo)
        let marker = UserDefaults.standard.string(forKey: "markerAddress")
        self.addressLbl.text = marker
        self.showAnimate()
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tagger = self.storyboard?.instantiateViewController(withIdentifier: "TaggerDetailViewController") as! TaggerDetailViewController
          let values = self.parraylist[indexPath.row]
    tagger.deedId = values.tag_id
        self.navigationController?.pushViewController(tagger, animated: true)
    }
    func downloadPListMarker(geo : String){
        print(geo)//18.5535633,73.802788
    //    let  geoPoint = String(format:"%f,%f", geo.latitude,geo.longitude) //("\(geo.latitude),\(geo.longitude)")//
    //    print(geoPoint)
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.permanent_deed_list
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@&geopoints=%@",userId,geo)// Geopoint = "18.553474,73.802670";
        print(paramString)
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
                print(jsonObj!)
                
                for values in jsonObj!{
                    let tag_id = (values as AnyObject).value(forKey: "tag_id") as! String
                    let need_name = (values as AnyObject).value(forKey: "need_name") as! String
                    let sub_types = (values as AnyObject).value(forKey: "sub_types") as! String
                    let icon_path = (values as AnyObject).value(forKey: "icon_path") as! String
                    let pdeed = pDeedList(tag_id: tag_id, sub_types: sub_types, need_name: need_name, icon_path: icon_path)
                    print(pdeed)
                    self.parraylist.append(pdeed)
                    
                  //  print(self.arrayTableViewData)
                }
                DispatchQueue.main.async{
                    self.plistTbl.reloadData()
                }
            }
            
        }
        
        task.resume()
        
    }
    
    @IBAction func closePopUp(_ sender: AnyObject) {
        //self.removeAnimate()
        self.view.removeFromSuperview()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
