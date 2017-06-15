//
//  Constants.swift
//  FigmaContacts
//
//  Created by Vinoth  on 14/06/17.
//  Copyright © 2017 Kovan. All rights reserved.
//

import Foundation

import UIKit

class Constants: NSObject {
    
    static let baseUrl = "https://restcountries.eu/rest/v1/"
    struct Endpoint {
        struct Contact {
            static let allCountries = "all"
        }
    }
    
    struct Persist {
        static let countries = "Countries"
    }
    
}
