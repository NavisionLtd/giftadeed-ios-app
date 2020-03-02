//  Constant.swift

//  GiftADeed
//  Created by nilesh_sinha on 04/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//  kshantechsoft@gmail.com
//  Rambo@16076
import UIKit
import SQLite
class Constant: NSObject {
    // Mark: pragma mark - Google Places App Key
    static let googleClientId = "YOUR GOOGLE CLIENT KEY"
    static let GooglePlacesApp_ID = "YOUR GOOGLE PLACES KEY"
    static let linkedinClientID = "YOUR DEVELOPER ACCOUNT KEY" // This feature is hidden in UI on Login Page
    static let linkedinClientSecret = "YOUR LINKED IN CLIENT SECRET KEY"
    static let GAD_IOS_LINK = "http://tiny.cc/h4533y";
    static let GAD_ANDROID_LINK = "http://tiny.cc/kwb33y";
    static let GAD_SHARE_TEXT = "Hey!\nI am using 'Gift-A-Deed' charity mobile app.\nYou can download it from:\n\niOS: \(Constant.GAD_IOS_LINK)\n\nAndroid: \(Constant.GAD_ANDROID_LINK)"
    static let GOOGLE_PLACES_BASE_URL = "YOUR GOOGLE PLACES API KEY"
    static let china_google_place = "GOOGLE PLACES URL WHICH IS USED IN CHINA ONLY"

    
    
    
    //Live Server
   static let BASE_URL =  "YOUR SERVER URL"
   static let Custom_BASE_URL = "YOUR SERVER URL/image/group_category/"

    static var database: Connection!
     static let AppleLoginTable = Table("AppleLoginTable")
    static let profileTable = Table("profile")
    static let preferenceTable = Table("preference")
    static let audianceTable = Table("audiance")
    static let sosTypeTable = Table("sosTypeTable")
    static let categoryTable = Table("categoryTable")
    static let multipreferenceTable = Table("multipreferenceTable")
    static let multiaudianceTable = Table("multiaudianceTable")
    static let settingTable = Table("setting")
    //Apple id login table
    static let loginid = Expression<Int>("loginid")
     static let appleid = Expression<String>("appleid")
       static let firstname = Expression<String>("firstname")
       static let lastname = Expression<String>("lastname")
       static let email = Expression<String>("email")
    //preference table coloumns
    static let id = Expression<Int>("id")
    static let prefid = Expression<String>("prefid")
    static let prefmapid = Expression<String>("prefmapid")
    static let prefname = Expression<String>("prefname")
    static let prefQty = Expression<String>("prefQty")
    static let prefstatus = Expression<String>("prefstatus")
    //Audiance Table coloumns
    static let aid = Expression<Int>("aid")
    static let audid = Expression<String>("audid")
    static let audname = Expression<String>("audname")
    static let audQty = Expression<String>("audQty")
    static let audstatus = Expression<String>("audstatus")
    //SOS type table coloumns
    static let sid = Expression<Int>("sid")
    static let sosid = Expression<String>("sosid")
    static let sosname = Expression<String>("sosname")
    static let sosstatus = Expression<String>("sosstatus")
    //Category table coloumns
    static let cid = Expression<Int>("cid")
    static let catid = Expression<String>("catid")
    static let catname = Expression<String>("catname")
    static let cattype = Expression<String>("cattype")
    static let catstatus = Expression<String>("catstatus")
    //End table
    //MultipleResourcepreference table coloumns
    static let mrid = Expression<Int>("mrid")
    static let mrefid = Expression<String>("mrefid")
    static let mrefname = Expression<String>("mrefname")
    static let mrefstatus = Expression<String>("mrefstatus")
    //End table
    //OtherAudiance Table coloumns
    static let mid = Expression<Int>("mid")
    static let mresid = Expression<String>("mresid")
    static let mresname = Expression<String>("mresname")
    static let mresstatus = Expression<String>("mresstatus")
    //End
    //Setting table coloumns
    static let set_id = Expression<Int>("set_id")
    static let sett_id = Expression<String>("sett_id")
    static let set_name = Expression<String>("set_name")
    static let set_status = Expression<String>("set_status")
    //End table
    
    static let resend_link = "resend_link.php"
    static let forgot_password = "forgot_pass.php"
    static let social_signup = "social_signup.php"
    static let first_login = "first_login.php"
    static let login = "login.php"
    static let app_signup = "app_signup.php"
   static let tagger_list = "deed_list.php" 
    static let MyTags = "MyTags.php"
    static let MyfullFillTags = "MyfullFillTags.php"
    static let top_taggers = "top_taggers.php"
    static let top_ten_fullfiller = "top_ten_fullfiller.php"
    static let tag_counter = "tag_counter.php"
    static let dashboard = "dashboard.php"
    static let advisory_board = "advisory_board.php"
    static let contact_us = "contact_us.php"
    static let app_notify = "app_notify.php"
    static let notification_count = "notification_count.php"
    static let country_list = "country_list.php"
    static let state_list = "state_list.php"
    static let city_list = "city_list.php"
    static let fetch_userprofile = "fetch_userprofile.php"
    static let update_userprofile = "update_userprofile.php"
    static let deed_details = "deed_details.php"
    static let edit_deed = "edit_deed.php"
    static let post_comment = "post_comment.php"
    static let report_user = "report_user.php"
    static let report_deed = "report_deed.php"
    static let endorse_deed = "endorse_deed.php"
    static let fulfilled_need = "fulfilled_need.php"
    static let tag_need = "tag_need.php"
    static let need_type = "need_type.php"
    static let saveimg = "saveimg.php"
    static let saveimg_ful = "saveimg_ful.php"
    static let active_user = "active_user.php"
    static let email_check = "email_check.php"
    static let location_based_test = "location_based_test.php"
    static let update_location = "update_location.php"
    static let update_device_type = "update_device_type.php"
    static let logout = "logout.php"
    static let getSetting = "get_application_settings.php"

    //Phase 3 Api
      static let createGroup = "create_group.php"
      static let showGroupList = "group_list.php"
      static let groupTagList = "group_home.php"
      static let groupInfo = "group_info.php"
      static let searchUser = "search_user.php"
      static let removeUser = "remove_member.php"
      static let addUser = "add_member.php"
      static let viewUser = "member_list.php"
      static let editGroup = "edit_group.php"
      static let deleteGroup =  "del_group.php"
      static let exitGroup = "exit_group.php"
      static let assignAdminToUser = "assign_admin.php"
      static let removeAdminFromUser = "dismiss_admin.php"
      static let suggest_sub_type = "suggest_sub_type.php"
      static let get_sub_type = "get_sub_type.php"
      static let get_user_orgs = "get_user_orgs.php"
      static let owned_groups = "owned_groups.php"
      static let sos_type = "get_sos_type.php"
      static let create_sos = "add_sos.php"
      static let sos_list = "sos_list.php"
      static let sos_details =  "sos_details.php"
      static let remove_sos = "remove_sos.php"
      static let get_multi_sub_type = "get_multi_sub_type.php"
      static let add_resources = "add_resource.php"
      static let list_resources = "resource_list.php"
      static let resource_details = "resource_details.php"
      static let permanent_deed_list = "permanent_deed_list.php"
      static let user_resource = "user_resource.php"
      static let del_resource = "del_resource.php"
      static let create_collaboration = "create_collaboration.php"
      static let group_creators_list = "group_creators_list.php"
      static let collaboration_request_list = "collaboration_request_list.php"
      static let users_collaboration_list = "users_collaboration_list.php"
      static let collaboration_information = "collaboration_information.php"
      static let collaboration_members_list = "collaboration_members_list.php"
      static let invite_group_creators = "invite_group_creators.php"
      static let edit_collaboration = "edit_collaboration.php"
      static let delete_collaboration = "delete_collaboration.php"
      static let edit_collaboration_request_status = "edit_collaboration_request_status.php"
      static let remove_member_from_collaboration = "remove_member_from_collaboration.php"
      static let country_emergency_number = "country_emergency_number.php"
     static let update_resource = "update_resource.php"
     static let ios_deed_list_filter  = "ios_deed_list_filter.php"
    static let app_setting = "application_settings.php";
    static let app_distance = "distancefetch.php";
}
struct Device {
    // iDevice detection code
    static let IS_IPAD             = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE           = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA           = UIScreen.main.scale >= 2.0
    static let SCREEN_WIDTH        = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT       = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH   = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH   = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH  < 568
    static let IS_IPHONE_5         = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    static let IS_IPHONE_6         = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    static let IS_IPHONE_6P        = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    static let IS_IPHONE_X         = IS_IPHONE && SCREEN_MAX_LENGTH == 812
}
