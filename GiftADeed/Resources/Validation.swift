//
//  Validation.swift
//  GiftADeed
//
//  Created by nilesh sinha on 25/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
import Foundation

class Validation: NSObject {

    static let sharedInstance = Validation()
    private override init() {}
    //need to change as something
    static let NETWORK_ERROR = "SORRY! Something went wrong. Please try later" //If not getting proper responce from server
    static let ERROR = "OOPS! No INTERNET. Please check your network connection" // Internet connection not avaliable
    static let LOADING_MESSAGE = "Please wait..."
    static let Success_msg = "Profile picture updated successfully"
    // MARK: - Login
    static let validLoginEmail = "Enter valid email"
    static let validPassword = "Enter valid password"
    static let checkPass = "Check your email for password."
    static let wrongPass = "Wrong password."
    
    // MARK: - Sign Up
    static let validFirstName = "Enter valid first name"
    static let validLastName = "Enter valid last name"
    static let validSignUpEmail = "Enter valid email"
    static let validSignUpTermsCondition = "Please accept Terms and Conditions"
    static let validUser = "User not registered with GAD"
    static let validRegisterEmail = "Enter a registered Email address"
    static let validEmailAlreadyRegister = "Email already registered with GAD."
    // MARK: - Country
    static let validCountry = "Please Select Country"
    static let validState = "Please Select State"
    static let validCity = "Please Select City"
    
    static let validImage = "Please Select Image to upload"
    // MARK :  - Home Screen
  //  static let validityImage = "Only Images uploaded during the past 48 hours are displayed"
    
    //Subcategory
     static let subSuccess_msg = "Your preference is successfully submited."
     static let subError_msg = "Something Went Wrong."
    static let subExist_msg = "Already Exist."
    
    func isValidEmail(Email:String) -> Bool {
        
        if Email.count != 0 {
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            let result = emailTest.evaluate(with: Email)
            return result
        }
        else{
            
            return false
        }
    }
    
    func isMobileValid(Mobile: String) -> Bool {
        
        let MOBILE_REGEX = "[0-9]{10}"
        let mobileTest = NSPredicate(format: "SELF MATCHES %@", MOBILE_REGEX)
        let result =  mobileTest.evaluate(with: Mobile)
        return result
    }
    
    func isPasswordSame(password: String , confirmPassword : String) -> Bool {
        
        if password == confirmPassword{
            return true
        }else{
            return false
        }
    }
    
    func isPasswordValid(Password : String) -> Bool{
      
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[!@#$%^&*()])[A-Za-z\\d$@$#!%*?&]{8,20}")
        return passwordTest.evaluate(with: Password)
    }
    
    func isPwdLenth(Password: String) -> Bool {
        
        if Password.count == 0{
           
            return false
        }else{
          
            if (Password.count) >= 6 && (Password.count) <= 20 {
                
                return true
            }
            else{
                
                return false
            }
        }
    }
    
    func isNameValid(Name : String) -> Bool {
        
        do {
            
            if (Name.count) >= 3 && (Name.count) <= 15 {
                
//                let regex = try NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
//                if regex.firstMatch(in: Name, options: [], range: NSMakeRange(0, Name.count)) != nil {
//                    return false
//                } else {
//                    return true
//                }
                return true
            }
            else{
                
                return false
            }
        }
        catch {
            
        }
        return false
    }
    
    func isLastNAmeValid(Name : String) -> Bool {
        
        do {
            
            if (Name.count) <= 15 {
                
//                let regex = try NSRegularExpression(pattern: ".*[^A-Za-z].*", options: [])
//                if regex.firstMatch(in: Name, options: [], range: NSMakeRange(0, Name.count)) != nil {
//                    return false
//                } else {
//                    return true
//                }
 return true
            }
            else{
                
                return false
            }
        }
        catch {
            
        }
        return false
    }
}
