//
//  ContactRouter.swift
//  FigmaContacts
//
//  Created by Vinoth  on 14/06/17.
//  Copyright © 2017 Kovan. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

enum ContactRouter: AlamoRequest {
    
    typealias contact = Constants.Endpoint.Contact
    
    case getCountry
    
    var path: String {
        switch self {
        case .getCountry:
            return contact.allCountries
        }
    }
    
    var method: HTTPMethod{
        switch self {
        case .getCountry:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .getCountry:
            return [:]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getCountry:
            return URLEncoding.queryString
        }
    }
}
