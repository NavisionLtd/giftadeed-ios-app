//
//  NumberPickerViewController.swift
//  EzPopup_Example
//
//  Created by Huy Nguyen on 6/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ANLoader

protocol NumberPickerViewControllerDelegate: class {
    func numberPickerViewController(sender: NumberPickerViewController, didSelectNumber number: Int,didSelectedMemberId:String,menuOption:String)
}

class NumberPickerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
  
    var menu = [String]()
   var adminOrmember = ""
    var selectedMemberId = ""
    weak var delegate: NumberPickerViewControllerDelegate?
    
    static func instantiate() -> NumberPickerViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(NumberPickerViewController.self)") as? NumberPickerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(adminOrmember)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        tableView.separatorInset = UIEdgeInsets.zero
    }

}

extension NumberPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = menu[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.numberPickerViewController(sender: self, didSelectNumber: indexPath.row, didSelectedMemberId: selectedMemberId, menuOption: adminOrmember)
    }
}
