//
//  APIManager.swift
//  FigmaContacts
//
//  Created by Vinoth  on 14/06/17.
//  Copyright © 2017 Kovan. All rights reserved.
//

import Foundation
import Alamofire

protocol AlamoRequest : URLConvertible, URLRequestConvertible {
    
    var headers : HTTPHeaders? { get }
    var method : HTTPMethod { get }
    var path : String { get }
    var parameters : Parameters { get }
    var parameterEncoding : ParameterEncoding { get }
}

extension AlamoRequest {
    var headers : HTTPHeaders? {
        return nil
    }
    
    var method : HTTPMethod {
        return .get
    }
    
    var parameterEncoding : ParameterEncoding {
        return URLEncoding(destination: .queryString)
    }
    
    func asURL() throws -> URL {
        return URL(string: Constants.baseUrl + path)!
    }
    
    func asURLRequest() throws -> URLRequest {
        return try URLRequest(url: self, method: method, headers: headers)
    }
}

class APIManager : NSObject {
    class func make(request : AlamoRequest, completion : @escaping (Any?) -> Void) {
        Alamofire.request(request, method: request.method, parameters: request.parameters, encoding: request.parameterEncoding, headers: request.headers).responseJSON { (response) in
            
            switch response.result {
            case .success(let json):
                completion(json)
            case .failure(let error):
                print("Error : ", error)
            }
        }
    }
}
