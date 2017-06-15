//
//  ContactCell.swift
//  FigmaContacts
//
//  Created by Vinoth on 6/13/17.
//  Copyright © 2017 Kovan. All rights reserved.
//

import UIKit
import FaveButton

class ContactCell: UITableViewCell {
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var favButton: FaveButton!
    @IBOutlet weak var contactImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!    
    var contactInfo: Contacts!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favButton.addTarget(self, action: #selector(self.favBtnTapped(sender:)), for: .touchUpInside)
    }

    func loadCellItem(contact : Contacts) {
        contactInfo = contact
        nameLabel.text = contact.name
        phoneLabel.text = contact.phone
        contactImgView.image = UIImage(data: contact.imgData as Data)
        favButton.isSelected = contact.isFavorite
    }
    
    func favBtnTapped(sender: FaveButton) {
        
        var isFav = contactInfo.isFavorite
        if sender.isSelected {
            isFav = true
            //print("Selected")
        } else {
            isFav = false
            //print("Deselected")
        }
        
        try! realm.write {
            contactInfo.isFavorite = isFav
            realm.add(contactInfo, update: true)
        }
        
    }

}
