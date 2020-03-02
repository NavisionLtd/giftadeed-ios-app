//
//  SendBirdViewController.swift
//  Billion Yogis_Example
//
//  Created by Darshan on 2/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//SendBirdViewController


import UIKit
import SendBirdSDK

class SendBirdViewController: UIViewController {
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var openChannelButton: UIButton!
    @IBOutlet weak var groupChannelButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var versionLabel: UILabel!
    var channels: [SBDOpenChannel] = []
    var channelListQuery: SBDOpenChannelListQuery?
    var connected: Bool
    
    required init?(coder aDecoder: NSCoder) {
        self.connected = false
        
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.connected = false
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.channelListQuery = SBDOpenChannel.createOpenChannelListQuery()
        
        self.loadChannels()
//        let userId = UserDefaults.standard.object(forKey: "sendbird_user_id") as? String
//        let nickname = UserDefaults.standard.object(forKey: "sendbird_nickname") as? String
        let memberId = UserDefaults.standard.string(forKey: "memberid") ?? "0"
        let name = UserDefaults.standard.string(forKey: "first_Name")
        self.userIdTextField.text = memberId
        self.nicknameTextField.text = name
        
        self.connected = false
        
        self.activityIndicatorView.isHidden = true
        self.openChannelButton.isEnabled = false
        self.groupChannelButton.isEnabled = false
        
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        if path != nil {
            let infoDict = NSDictionary(contentsOfFile: path!)
            let sampleUIVersion = infoDict!["CFBundleShortVersionString"] as! String
            let version = String(format: "SDK v%@\nSample UI v%@ for Swift 3 ", SBDMain.getSDKVersion(), sampleUIVersion)
          //  self.versionLabel.text = version
        }
    }
    func loadChannels() {
        if self.channelListQuery?.isLoading() == true {
            return
        }
        
        if self.channelListQuery?.hasNext == false {
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                print("Channel list loading error: %@", error)
//                if self.refreshControl?.isRefreshing == true {
//                    self.refreshControl?.endRefreshing()
//                }
                
                return
            }
            
            if channels == nil || channels!.count == 0 {
                return
            }
            
            for channel in channels! {
                self.channels.append(channel)
                print(channel.name)
            }
            
            DispatchQueue.main.async(execute: {
               // self.tableView.reloadData()
//                if self.refreshControl?.isRefreshing == true {
//                    self.refreshControl?.endRefreshing()
//                }
            })
        })
    }
    @IBAction func menuBtnPress(_ sender: Any) {
        if let drawer = self.drawer() ,
            let manager = drawer.getManager(direction: .left){
            let value = !manager.isShow
            drawer.showLeftSlider(isShow: value)
        }
    }
    @IBAction func clickConnectButton(_ sender: AnyObject) {
        if self.userIdTextField.text?.characters.count == 0 {
            let alert = UIAlertController(title: "Error", message: "User ID is required.", preferredStyle: UIAlertControllerStyle.alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(closeAction)
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
            
            return;
        }
        
        if self.nicknameTextField.text?.characters.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Nickname is required.", preferredStyle: UIAlertControllerStyle.alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(closeAction)
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
            
            return;
        }
        
    
            DispatchQueue.main.async(execute: {
                self.activityIndicatorView.isHidden = false
                self.activityIndicatorView.startAnimating()
            })
            self.userIdTextField.isEnabled = false
            SBDMain.connect(withUserId: self.userIdTextField.text!, completionHandler: { (user, error) in
                if error == nil {
                    SBDMain.updateCurrentUserInfo(withNickname: self.nicknameTextField.text, profileUrl: nil, completionHandler: { (error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(closeAction)
                            DispatchQueue.main.async(execute: {
                                self.present(alert, animated: true, completion: nil)
                                self.activityIndicatorView.isHidden = true
                                self.activityIndicatorView.stopAnimating()
                            })
                            
                            return
                        }
                        
                        UserDefaults.standard.set(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
                        UserDefaults.standard.set(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_nickname")
                        
                        DispatchQueue.main.async(execute: {
                            self.connected = true
                            self.openChannelButton.isEnabled = true
                            self.groupChannelButton.isEnabled = true
                          //  self.connectButton.setTitle("Disconnect", for: UIControlState())
//                            let vc = OpenChannelListViewController()
//                            self.navigationController?.pushViewController(vc, animated: true)
                            let vc = OpenChannelViewController()
                            vc.title = "Inspire community"//self.channels[0].name //"Inspire community"
                            vc.senderId = SBDMain.getCurrentUser()?.userId
                            vc.senderDisplayName = SBDMain.getCurrentUser()?.nickname
                            vc.channel = self.channels[0]
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                            self.activityIndicatorView.isHidden = true
                            self.activityIndicatorView.stopAnimating()
                        })
                    })
                }
                else {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld-%@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                        
                        self.userIdTextField.isEnabled = true
                        
                        self.activityIndicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                    })
                }
            })
        
    }
    
    @IBAction func clickOpenChannelButon(_ sender: AnyObject) {
        let vc = OpenChannelListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickGroupChannelButton(_ sender: AnyObject) {
        let vc = GroupChannelListViewController()
        vc.setUser((SBDMain.getCurrentUser()?.userId)!, aUserName: (SBDMain.getCurrentUser()?.nickname)!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

