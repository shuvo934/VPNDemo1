//
//  GetConnectionInfo.swift
//  PhoenixVPN
//
//  Created by MacBook Pro on 2/2/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import Foundation
import Alamofire

struct GetConnectionInfo {
    let url = "http://www.bdcorpus.com:8000/vdr/APIv01/"
    
    func getStatus(endPoint: String) {
        AF.request(url + endPoint, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { (responseData) in
            print("We got the Response")
        }
    
    }

}
