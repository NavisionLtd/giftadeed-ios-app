//
//  HelpViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 09/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
/*
 •    Clicking this option should direct the user to the Help page of the app.
 •    Contents needed for this page
 */
//   let url = URL (string: "http://kshandemo.co.in/GAD_MobileStaticPages/giftadeed/Help-2.html")
//
import UIKit
import Localize_Swift
import EFInternetIndicator
class HelpViewController: UIViewController, UIGestureRecognizerDelegate,InternetStatusIndicable {
   
     var internetConnectionIndicator:InternetViewIndicator?
     @IBOutlet  var outletWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
       let url = URL (string: "https://giftadeed.com/pages/FAQ.html")
        let requestObj = URLRequest(url: url!)
        
        outletWebView.loadRequest(requestObj)
    }
//    let kHeaderSectionTag: Int = 6900;
//
//    @IBOutlet weak var tableView: UITableView!
//
//    var expandedSectionHeaderNumber: Int = -1
//    var expandedSectionHeader: UITableViewHeaderFooterView!
//    var sectionItems: Array<Any> = []
//    var sectionNames: Array<Any> = []
//    var serialNumber: Array<Any> = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//setText()
//        // Do any additional setup after loading the view.
//        serialNumber = ["01.","02.","03.","04.","05.","06.","07.","08.","09.","10.","11.","12."];
//
//        sectionNames = [ "What social issue does GAD plan to address?",
//                         "Is this app accessible globally?",
//                         "What information I share is public to other users? Can I maintain privacy as a user?",
//                         "How do I tag the needy person?",
//                         "How do I know that the needs of the person I tagged have been fulfilled?",
//                         "Is there any monetary exchange expected while fulfilling a need?",
//                         "Can I fulfill a need that has already been fulfilled?",
//                         "Who all get notified once I tag a need?",
//                         "Why does the need I tag do not show up after some time?",
//                         "How are the Reward points calculated?",
//                         "What option do I have to report a need I think is not genuine?",
//                         "I am not receiving any emails from Gift-A-Deed. What do I do?"
//                        ];
//
//        sectionItems = [
//             ["Gift-A-Deed app hopes to bridge the gap between the ‘haves’ and the ‘have-nots’ with regards to life’s basic necessities."],
//             ["Currently, this is app is available only in Hong Kong, India, Canada, China, France, and Thailand. We do plan to launch this app world-wide in the coming future."],
//             ["Only your Full Name will be visible to others.If you wish, you can go Anonymous by changing the Privacy Settings by visiting the My Profile option."],
//             ["To tag a Needy person, just go to the Tag a Deed section of the app. On the Tag a Deed page, fill in the required information, and click a photo of the needy person (optional), and you are all set to post the tag."],
//             ["Once your tag has been fulfilled, you will get a notification regarding the same."],
//             ["No. There is no monetary exchange expected while fulfilling a need."],
//             ["No. You cannot fulfill a need that has already been fulfilled."],
//             ["All the Gift-A-Deed app users who are in a vicinity of 10 km from the tag will get notified once you tag a deed."],
//             ["All needs have a predefined validity that is set during tagging the need itself. All the needs that have passed the validity stop being shown in the app. Also, whenever a tag is fulfilled, it stops being shown in the app."],
//             ["For every successful tag, the user earns 100 reward points. Similarly, for every fulfillment by the user, the user earns 200 reward points."],
//             ["You can report a user, or a need to the admin by going to the details page of that need."],
//             ["Please check your Junk/Spam folder to check whether emails from Gift-A-Deed are going to that folder. If mails form Gift-A-Deed are going to your Junk/Spam folder, then please mark them as ‘Safe’. This way, the emails from Gift-A-Deed will start landing in your Inbox."]
//            ];
//
//        self.tableView!.tableFooterView = UIView()
//    }
//func setText()
//{
//    sectionNames = ["What social issue does GAD plan to address?".localized()]
//    sectionItems = ["".localized()]
//    }
    @IBAction func menuBarAction(_ sender: Any) {

        DispatchQueue.main.async {

            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "aboutUs") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
//
//    // MARK: - Tableview Methods
//    func numberOfSections(in tableView: UITableView) -> Int {
//        if sectionNames.count > 0 {
//            tableView.backgroundView = nil
//            return sectionNames.count
//        } else {
//
//            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 100))
//            messageLabel.text = "Retrieving data.\nPlease wait."
//            messageLabel.numberOfLines = 5;
//            messageLabel.textAlignment = .natural;
//            messageLabel.font = UIFont(name: "HelveticaNeue", size: 10.0)!
//            messageLabel.sizeToFit()
//            self.tableView.backgroundView = messageLabel;
//        }
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (self.expandedSectionHeaderNumber == section) {
//            let arrayOfItems = self.sectionItems[section] as! NSArray
//            return arrayOfItems.count;
//        } else {
//            return 0;
//        }
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let view = UIView(frame:CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
//
//        let serialNumberLabel =  UILabel(frame:CGRect(x: 0, y: 5, width: 25, height: 18))
//        serialNumberLabel.font = UIFont.boldSystemFont(ofSize: 14)
//        serialNumberLabel.text = self.serialNumber[section] as? String
//
//        let questionLabel =  UILabel(frame:CGRect(x: 28, y: 5, width: tableView.frame.size.width - 40, height: 18))
//        questionLabel.font = UIFont.systemFont(ofSize: 14)
//        questionLabel.text = (self.sectionNames[section] as? String)?.localized()
//        questionLabel.numberOfLines = 3
//        questionLabel.lineBreakMode = .byWordWrapping
//        questionLabel.sizeToFit()
//
//        let imageViewGame = UIImageView(frame: CGRect(x: tableView.frame.size.width - 22, y: 8, width: 20, height: 20))
//        let image = UIImage(named: "Chevron-Dn-Wht");
//        imageViewGame.image = image;
//
//        imageViewGame.tag = kHeaderSectionTag + section
//
//        let borderView = UIView(frame:CGRect(x: tableView.frame.origin.y, y: 0, width: tableView.frame.size.width, height: 1))
//        borderView.backgroundColor = UIColor.black
//
//        view.backgroundColor = UIColor.groupTableViewBackground
//        view.addSubview(serialNumberLabel)
//        view.addSubview(questionLabel)
//        view.addSubview(imageViewGame)
//        view.addSubview(borderView)
//
//        view.tag = section
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(HelpViewController.sectionHeaderWasTouched(_:)))
//        tap.delegate = self
//        view.isUserInteractionEnabled = true
//        view.addGestureRecognizer(tap)
//
//        return view
//    }
//
////    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
////
////        let view = UIView(frame:CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
////        view.backgroundColor = UIColor.black
////        return view
////    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//        if Device.IS_IPHONE_5 {
//
//            if section == 1 || section == 3 || section == 7 || section == 9 {
//
//                return 25.0;
//            }
//            else if section == 2{
//
//                return 60.0;
//            }
//            else{
//
//                return 40.0;
//            }
//        }
//        else if Device.IS_IPHONE_6{
//
//            if section == 1 || section == 3 || section == 6 || section == 7 || section == 9 {
//
//                return 30.0;
//            }
//            else{
//
//                return 40.0;
//            }
//        }
//        else if Device.IS_IPAD{
//
//            return 40.0;
//        }
//        else{
//
//            return 40.0;
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
//        return 1;
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! HelpTableViewCell
//        let section = self.sectionItems[indexPath.section] as! NSArray
//        cell.outletMessage?.textColor = UIColor.black
//        cell.outletMessage?.text = (section[indexPath.row] as? String)?.localized()
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    // MARK: - Expand / Collapse Methods
//    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
//
//        let headerView = sender.view
//        let section    = headerView?.tag
//        let eImageView = headerView?.viewWithTag(kHeaderSectionTag + section!) as? UIImageView
//
//        if (self.expandedSectionHeaderNumber == -1) {
//            self.expandedSectionHeaderNumber = section!
//            tableViewExpandSection(section!, imageView: eImageView!)
//        } else {
//            if (self.expandedSectionHeaderNumber == section) {
//                tableViewCollapeSection(section!, imageView: eImageView!)
//            } else {
//                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
//                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
//                tableViewExpandSection(section!, imageView: eImageView!)
//            }
//        }
//    }
//
//    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
//
//        let sectionData = self.sectionItems[section] as! NSArray
//
//        self.expandedSectionHeaderNumber = -1;
//        if (sectionData.count == 0) {
//            return;
//        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
//            })
//            var indexesPath = [IndexPath]()
//            for i in 0 ..< sectionData.count {
//                let index = IndexPath(row: i, section: section)
//                indexesPath.append(index)
//            }
//            self.tableView!.beginUpdates()
//            self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
//            self.tableView!.endUpdates()
//        }
//    }
//
//    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
//
//        let sectionData = self.sectionItems[section] as! NSArray
//
//        if (sectionData.count == 0) {
//            self.expandedSectionHeaderNumber = -1;
//            return;
//        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//            })
//            var indexesPath = [IndexPath]()
//            for i in 0 ..< sectionData.count {
//                let index = IndexPath(row: i, section: section)
//                indexesPath.append(index)
//            }
//            self.expandedSectionHeaderNumber = section
//            self.tableView!.beginUpdates()
//            self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
//            self.tableView!.endUpdates()
//
//            if section == 11{
//
//                self.goToBottom();
//            }
//        }
//    }
//
//     // MARK: - Scroll Up
//    func goToBottom() {
//
//        do {
//            let lastIndexPath = self.lastIndexPath()
//            self.tableView.scrollToRow(at: lastIndexPath!, at: .bottom, animated: false)
//        } catch let exception {
//            print("Error")
//        }
//    }
//
//    func lastIndexPath() -> IndexPath? {
//
//        do {
//            let lastSectionIndex: Int = max(0, self.tableView.numberOfSections - 1)
//            let lastRowIndex: Int = max(0, self.tableView.numberOfRows(inSection: lastSectionIndex) - 1)
//            return IndexPath(row: lastRowIndex, section: lastSectionIndex)
//        } catch let exception {
//            print("Error")
//        }
//    }
}
