//
//  Utils.swift
//  FigmaContacts
//
//  Created by Vinoth  on 14/06/17.
//  Copyright © 2017 Kovan. All rights reserved.
//

import UIKit
import Material
import libPhoneNumber_iOS.NBPhoneNumberUtil
import SwiftMessages
import SwiftyJSON

class Utils: NSObject {
    
    static let baseUIColor = Color.grey.base
    
    
    //MARK : NavigationBar Appearance  FF3366
    class func navigationBarAppearance() {
        
        
        
        UINavigationBar.appearance().barTintColor = UIColor.red
        UINavigationBar.appearance().tintColor    = Utils.baseUIColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : Color.grey.base]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().clipsToBounds = false
        
        
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-60, -60), for: .default)
        
    }
    
    //Mark : Check validMobile
    class func isvalidMobile(phone: String) -> Bool {
        let phoneUtil = NBPhoneNumberUtil()
        
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(phone, defaultRegion: "IN")
            
            switch phoneUtil.getNumberType(phoneNumber) {
            case .FIXED_LINE_OR_MOBILE, .MOBILE:
                print("It's mobile number OR Fixed line", phone)
                return true
            default:
                print("Not a mobile number")
                return false
            }
            
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return false
        }

    }
    
    //Mark : Check Valid Email
    class func isValidEmail(email:String) -> Bool {
        print("validate emilId: \(email)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
    
    //SwiftMessage Config
    class func swiftMeassageView(title : String, message : String, theme : Theme) -> MessageView {
        
        let messageView = MessageView.viewFromNib(layout: .CardView)
        messageView.configureTheme(theme)
        messageView.configureDropShadow()
        messageView.configureContent(title: title, body: message)
        messageView.button!.setTitle("Done", for: .normal)
        messageView.button?.isHidden = true
        
        var messageViewConfig = SwiftMessages.Config()
        messageViewConfig.presentationStyle = .top
        messageViewConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        
        return messageView
    }
    
    class func compressImage(image:UIImage) -> (UIImage, NSData) {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        let maxHeight : CGFloat = 1136.0
        let maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else{
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        
        let rect = CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size);
        image.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(image!, compressionQuality);
        UIGraphicsEndImageContext();
        
        return (image!, imageData! as NSData)
    }
    
    //Persist CountryData
    class func persistCountry() {
        if realm.objects(Country.self).count < 0 {
            APIManager.make(request: ContactRouter.getCountry) { (response) in
                guard let _ = response else {
                    return
                }
                
                let countryjson = JSON(response!)
                for (_,subJson):(String, JSON) in countryjson {
                    //print("name : ", subJson["name"])
                    try! realm.write {
                        let country = Country()
                        country.name = subJson["name"].stringValue
                        realm.add(country)
                    }
                }
            }
            
        }
    }

}
