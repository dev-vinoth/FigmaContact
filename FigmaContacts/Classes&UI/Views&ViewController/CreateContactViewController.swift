//
//  CreateContactViewController.swift
//  FigmaContacts
//
//  Created by Vinoth  on 13/06/17.
//  Copyright © 2017 Kovan. All rights reserved.
//

import UIKit
import Material
import SwiftMessages
import RealmSwift
import SwiftyJSON
import ImagePicker

class CreateContactViewController: UITableViewController {
    fileprivate var backButton: IconButton!
    fileprivate var saveButton = RaisedButton()
    fileprivate var cancelButton = RaisedButton()
    fileprivate var userImage = UIImage()
    
    fileprivate let phoneSpinList = ["Mobile", "Phone"]
    fileprivate let emailSpinList = ["Home", "Office"]
    fileprivate var countriesArr = [String]()

    @IBOutlet weak var countryPickerView: UIPickerView!
    @IBOutlet weak var emailSpinner: LBZSpinner!
    @IBOutlet weak var phoneSpinner: LBZSpinner!
    @IBOutlet var createContactView: UITableView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var nameTxtField: TextField!
    @IBOutlet weak var phoneTxtField: TextField!
    @IBOutlet weak var emailTxtField: TextField!
    @IBOutlet weak var countryTxtField: TextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTxtField.delegate = self
        
        setUpViews()
        getCountries()
        
    }
    
    private func getCountries() {
        self.countriesArr = []
        if realm.objects(Country.self).count > 0 {
            for country in realm.objects(Country.self) {
                countriesArr.append(country.name)
            }
            countryPickerView.reloadAllComponents()

        } else {
            APIManager.make(request: ContactRouter.getCountry) { (response) in
                guard let _ = response else {
                    return
                }
                let countryjson = JSON(response!)
                for (_,subJson):(String, JSON) in countryjson {
                    self.countriesArr.append(subJson["name"].stringValue)
                }
                self.countryPickerView.reloadAllComponents()
            }
        }
    }
    
    
    func saveBtnTapped() {
        
        if nameTxtField.text == "" || phoneTxtField.text == "" || emailTxtField.text == "" || countryTxtField.text == "" {
            let SMView = Utils.swiftMeassageView(title: "Warning", message: "All fiels are required!", theme: .warning)
            SwiftMessages.show(view: SMView)
        } else {
            
            if !Utils.isvalidMobile(phone: phoneTxtField.text!) {
                let SMView = Utils.swiftMeassageView(title: "Warning", message: "Enter valid Phone number!", theme: .warning)
                SwiftMessages.show(view: SMView)
            } else if !Utils.isValidEmail(email: emailTxtField.text!) {
                let SMView = Utils.swiftMeassageView(title: "Warning", message: "Enter valid Email", theme: .warning)
                SwiftMessages.show(view: SMView)
            } else {
                var imgData = NSData()
                if userImage.imageAsset != nil {
                    imgData = Utils.compressImage(image: userImage).1
                } else {
                    imgData = Utils.compressImage(image: #imageLiteral(resourceName: "maleAvatar")).1
                }
                try! realm.write {
                    let contact = Contacts()
                    contact.id   = autoMd5Id()
                    contact.name = nameTxtField.text!
                    contact.phone = phoneTxtField.text!
                    contact.email = emailTxtField.text!
                    contact.country = countryTxtField.text!
                    contact.imgData = imgData
                    realm.add(contact)
                }
                
                dismiss(animated: true, completion: nil)
            }
        }
        
    }

    func cancelBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func backBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imgGestureTapped(sender: UITapGestureRecognizer) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    


}

//Mark : ImagePicker Delegate
extension CreateContactViewController : ImagePickerDelegate {
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }

    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        userImgView.image = images[0]
        userImage = images[0]
    }
}

//Mark : Textfield & Spinner delegate
extension CreateContactViewController : TextFieldDelegate, LBZSpinnerDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneTxtField {
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 10
        } else {
            return true
        }
    }
    
    func spinnerChoose(_ spinner:LBZSpinner, index:Int,value:String) {
        //print("Spinner : \(spinner) : { Index : \(index) - \(value) }")
    }
}

//MARK : SetupViews
extension CreateContactViewController{
    
    fileprivate func setUpViews() {
        setUpTopToolbar()
        setUpFooterView()
        setUpSpinner()
        setUpPickerView()
    }
    
    fileprivate func setUpTopToolbar() {
        backButton = IconButton(image: Icon.cm.arrowBack)
        
        toolbarController?.toolbar.leftViews = [backButton]
        toolbarController?.toolbar.title = "New Contact"
        
        backButton.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
    }
    
    fileprivate func setUpFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: self.view.bounds.size.height - 120, width: self.view.bounds.size.width, height: 75))
        
        cancelButton.title = "CANCEL"
        cancelButton.frame = CGRect(x: 5, y: footerView.bounds.size.height / 4, width: (self.view.bounds.width / 2) - 10, height: footerView.bounds.height / 2)
        cancelButton.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        
        saveButton.title = "SAVE"
        saveButton.frame = CGRect(x: (view.bounds.size.width / 2) + 5, y: footerView.bounds.size.height / 4, width: (self.view.bounds.width / 2) - 10, height: footerView.bounds.height / 2)
        saveButton.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        saveButton.borderColor = Color.grey.darken2
        
        
        footerView.addSubview(cancelButton)
        footerView.addSubview(saveButton)
        
        createContactView.tableFooterView = footerView
    }
    
    fileprivate func setUpSpinner() {
        phoneSpinner.delegate = self
        phoneSpinner.text = phoneSpinList[0]
        phoneSpinner.updateList(phoneSpinList)
        emailSpinner.text = emailSpinList[0]
        emailSpinner.updateList(emailSpinList)
    }
    
    fileprivate func setUpPickerView() {
        //Country
        countryPickerView.removeFromSuperview()
        countryTxtField.inputView = countryPickerView
        
        //Image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgGestureTapped))
        userImgView.isUserInteractionEnabled = true
        userImgView.addGestureRecognizer(tapGesture)
    }

}

//MARK : PickerView Delegate
extension CreateContactViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countriesArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countriesArr.count

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTxtField.text = countriesArr[row]

    }
}

