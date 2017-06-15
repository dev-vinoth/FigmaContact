//
//  ContactListViewController.swift
//  FigmaContacts
//
//  Created by Vinoth on 6/13/17.
//  Copyright © 2017 Kovan. All rights reserved.
//

import UIKit
import RealmSwift
import Material

class ContactListViewController: UIViewController {
    @IBOutlet weak var noContactView: UIView!
    @IBOutlet weak var contactTableView: UITableView!
    
    fileprivate var contactArr = [Contacts]()
    fileprivate var searchedContactArr = [Contacts]()
    fileprivate var searchButton: IconButton!
    fileprivate var addButton: IconButton!
    fileprivate var menuButton: IconButton!
    
    var shouldShowSearchResults = false
    var flag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSearchBar()
        contactTableView.backgroundView = noContactView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getContacts()
    }
    
    
    fileprivate func getContacts() {
        contactArr = []
        for contact in realm.objects(Contacts.self) {
            //print(contact)
            contactArr.append(contact)
        }
        contactTableView.reloadData()
    }
    
    private func prepareSearchBar() {
        searchBarController?.title = "asdsad"
        searchBarController?.searchBar.delegate = self
        searchBarController?.searchBar.textField.textAlignment = .center

        guard let searchBar = searchBarController?.searchBar else {
            return
        }
        searchBar.delegate = self
        
        searchBarController?.searchBar.textField.isHidden = true
        
        addButton = IconButton(image: Icon.cm.add)
        searchButton = IconButton(image: Icon.cm.search)
        menuButton = IconButton(image: Icon.cm.menu)
        
        addButton.addTarget(self, action: #selector(addContact), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        
        searchBar.rightViews = [addButton, searchButton]
        searchBar.leftViews  = [menuButton]
    }
    
    func addContact() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addContactVC = storyboard.instantiateViewController(withIdentifier: "CreateContact") as! CreateContactViewController
        let toolBarVC = ToolbarController(rootViewController: addContactVC)
        
        toolBarVC.modalTransitionStyle = .crossDissolve
        self.present(toolBarVC, animated: true, completion: nil)
    }
    
    func searchTapped() {
        if flag {
            searchBarController?.searchBar.textField.isHidden = false
            searchBarController?.searchBar.textField.becomeFirstResponder()
            flag = false
        } else {
            searchBarController?.searchBar.textField.isHidden = true
            searchBarController?.searchBar.textField.resignFirstResponder()
            flag = true
        }

    }
    
}

//MARK : TableView Datasource & Delegate
extension ContactListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if contactArr.count > 0 {
            contactTableView.separatorStyle = .singleLine
            noContactView.isHidden = true
            return 1
        } else {
            contactTableView.separatorStyle = .none
            noContactView.isHidden = false
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!shouldShowSearchResults || searchBarController?.searchBar.textField.text == ""){
            return contactArr.count
        }
        else {
            return searchedContactArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = contactTableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        
        var contactInfo : Contacts!
        if (!shouldShowSearchResults || searchBarController?.searchBar.textField.text == ""){
            contactInfo = contactArr[indexPath.row]
        } else {
            contactInfo = searchedContactArr[indexPath.row]
        }
        
        //load all contacts
        cell.loadCellItem(contact: contactInfo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (deleteAction, indexPath) -> Void in

            let listToBeDeleted = realm.objects(Contacts.self).filter("id=%@",self.contactArr[indexPath.row].id)
            try! realm.write{
                
                realm.delete(listToBeDeleted)
                self.getContacts()
            }
        }
        
        return [deleteAction]

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!shouldShowSearchResults || searchBarController?.searchBar.textField.text == ""){
            if let phoneNumUrl = URL(string: "tel://\(contactArr[indexPath.row].phone)"), UIApplication.shared.canOpenURL(phoneNumUrl) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(phoneNumUrl)
                } else {
                    UIApplication.shared.openURL(phoneNumUrl)
                }
            }
        }
        else {
            if let phoneNumUrl = URL(string: "tel://\(searchedContactArr[indexPath.row].phone)"), UIApplication.shared.canOpenURL(phoneNumUrl) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(phoneNumUrl)
                } else {
                    UIApplication.shared.openURL(phoneNumUrl)
                }
            }
        }
 
    }
}

//MARK : Search Delegate
extension ContactListViewController : SearchBarDelegate {
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        textField.resignFirstResponder()
        shouldShowSearchResults = false
        contactTableView.reloadData()

    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        shouldShowSearchResults = true
        performSearch(searchStr: searchBar.textField.text!)
        contactTableView.reloadData()
    }
    
    func performSearch(searchStr : String) {
        searchedContactArr = contactArr.filter() {
            ($0.name.lowercased() as NSString).contains(searchStr.lowercased())
        }
        contactTableView.reloadData()
    }
    
}
