//
//  AvtaarImgViewController.swift
//  GiftADeed
//
//  Created by Darshan on 8/13/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
import ANLoader
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Toast_Swift
import EFInternetIndicator
class AvtaarImgViewController: UIViewController, CLLocationManagerDelegate , UICollectionViewDelegate ,UICollectionViewDataSource,InternetStatusIndicable {
    var internetConnectionIndicator:InternetViewIndicator?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return menuImageArr.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MenuCollectionViewCell
        
        cell.layer.cornerRadius=4.0
        cell.layer.borderWidth=1.0
        cell.layer.borderColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1).cgColor
        print(menuImageArr.count)
        cell.avtarImg.clipsToBounds = true
        cell.avtarImg.layer.borderWidth = 0.5
        cell.avtarImg.layer.borderColor = UIColor.black.cgColor
        cell.avtarImg.image = menuImageArr[indexPath.row] as! UIImage
        
        if selectedIndexPath != nil && indexPath == selectedIndexPath {
            cell.chkIcon.isHidden = false
            cell.chkIcon.image = UIImage (named:"verified" )
            
        }else{
            
            cell.chkIcon.isHidden = true
        }
        
        
        return cell;
    }
    
    
    // Firebase services
    var database = FIRDatabase.database()
    var storage = FIRStorage.storage()
    var menuImageArr : NSMutableArray = []
   var selectedIndexPath: IndexPath?
    var selectedUrl = ""
    let defaults = UserDefaults.standard
    var userId = ""
    @IBOutlet weak var avtarCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
          userId = defaults.value(forKey: "User_ID") as! String
showAnimate()
     downloadProfileImg()
        // Do any additional setup after loading the view.
    }
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
        DispatchQueue.main.async {
            
            UserDefaults.standard.set(self.selectedUrl, forKey: "url")
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "profile") as! UINavigationController
            
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        
    }
    func downloadProfileImg(){
        
        let dbRef = database.reference().child("liveAvtaars")
        dbRef.observeSingleEvent(of:.value) { (snapshot) in
            if !snapshot.exists() { return }
            
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                print(data)
                let object = data.value as? [String:AnyObject]
                let id = object?["id"]
                let downloadUrl = object?["url"]
                print(downloadUrl!)
                let storageRef = self.storage.reference(forURL: downloadUrl as! String)
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                    // Create a UIImage, add it to the array
                    let pic = UIImage(data: data!)
                    self.menuImageArr.add(pic as Any)
             [self.avtarCollectionView .reloadData()]
                 
                }
            
            }
        }
        
    }
    @IBAction func doneBtnPress(_ sender: UIButton) {
        DispatchQueue.main.async {
         
            UserDefaults.standard.set(self.selectedUrl, forKey: "url")
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "profile") as! UINavigationController
          
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        
        
//    }
    }
    
    @IBAction func cloaseBtnPressed(_ sender: UIButton) {
          removeAnimate()
    }
    func closeBtnPress(_ sender: UIButton) {
      
    }
    //MARK: - Collection delegate and datasource methods
   
    
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! MenuCollectionViewCell
         cell.chkIcon.isHidden = false
        cell.chkIcon.image = UIImage (named:"verified" )
        self.selectedIndexPath = indexPath
  
        if indexPath.row == 0 {
          
            selectedUrl = "1"
                
            
        }
        if indexPath.row == 1 {
            
            selectedUrl = "2"
                    
            
        }
        if indexPath.row == 2 {
            
            selectedUrl = "3"
            
            
        }
        if indexPath.row == 3 {
            
            selectedUrl = "4"
            
            
        }
        if indexPath.row == 4 {
            
            selectedUrl = "5"
            
            
        }
        if indexPath.row == 5 {
            
            selectedUrl = "6"
            
            
        }
        if indexPath.row == 6 {
            
            selectedUrl = "7"
            
            
        }
        if indexPath.row == 7 {
            
            selectedUrl = "8"
            
            
        }
        if indexPath.row == 8 {
            
            selectedUrl = "9"
            
            
        }
        if indexPath.row == 9 {
            
            selectedUrl = "10"
            
        }
        if indexPath.row == 10 {
            
            selectedUrl = "11"
            
        }
        if indexPath.row == 11 {
            
            selectedUrl = "12"
            
        }
        if indexPath.row == 12 {
            
            selectedUrl = "13"
            
        }
        if indexPath.row == 13 {
            
            selectedUrl = "14"
            
        }
        if indexPath.row == 14 {
            
            selectedUrl = "15"
            
        }
        if indexPath.row == 15 {
            
            selectedUrl = "16"
            
        }
        if indexPath.row == 16 {
            
            selectedUrl = "17"
            
        }
        if indexPath.row == 17{
            
            selectedUrl = "18"
            
        }
        if indexPath.row == 18 {
            
            selectedUrl = "19"
            
        }
        if indexPath.row == 19 {
            
            selectedUrl = "20"
            
        }
        if indexPath.row == 20 {
            
            selectedUrl = "21"
            
        }
        if indexPath.row == 21 {
            
            selectedUrl = "22"
            
        }
        if indexPath.row == 22 {
            
            selectedUrl = "23"
            
        }
        if indexPath.row == 23 {
            
            selectedUrl = "24"
            
        }
        if indexPath.row == 24 {
            
            selectedUrl = "25"
            
        }
        if indexPath.row == 25 {
            
            selectedUrl = "26"
            
        }
        if indexPath.row == 26 {
            
            selectedUrl = "27"
            
        }
        if indexPath.row == 27 {
            
            selectedUrl = "28"
            
        }
        if indexPath.row == 28 {
            
            selectedUrl = "29"
            
        }
        if indexPath.row == 29 {
            
            selectedUrl = "30"
            
        }
        if indexPath.row == 30 {
            
            selectedUrl = "31"
            
        }
        if indexPath.row == 31 {
            
            selectedUrl = "32"
            
        }
        if indexPath.row == 32 {
            
            selectedUrl = "33"
            
        }
        if indexPath.row == 33 {
            
            selectedUrl = "34"
            
        }
        if indexPath.row == 34 {
            
            selectedUrl = "35"
            
        }
       
            //UPLOAD AVTAAR TO FIREBASE
            
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
      
        cell.avtarImg.image = menuImageArr[indexPath.row] as? UIImage
        print(self.selectedUrl)
        print(cell.avtarImg.image as Any)
                    PostServiceFireBase.create(for: cell.avtarImg.image!, path: selectedUrl) { (downloadURL) in
                        guard let downloadURL = downloadURL else {
                            print("Download url not found")
                            //   Toast(text: "Failed to upload image").show()
                            print("Failed to upload image")
                            return
                        }
                        let array = ["email":"",
                                     "userid":self.userId,
                                     "name": "",
                                     "photourl": downloadURL
                            ] as [String : Any]
                        let dbRef = self.database.reference().child("FirbaseBranch"+self.userId)
                        
                        dbRef.setValue(array)
                      
                        DispatchQueue.main.async {
                            
                            self.view.hideAllToasts()
                            ANLoader.hide()
                               self.view.makeToast("Profile picture successfully updated".localized())
                        }
                        self.removeAnimate()  
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell: MenuCollectionViewCell = collectionView.cellForItem(at: indexPath) as! MenuCollectionViewCell
        
         cell.chkIcon.isHidden = true
        selectedIndexPath = nil
    }


}

extension AvtaarImgViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth/2, height: collectionViewWidth/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

