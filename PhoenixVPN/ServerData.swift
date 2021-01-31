//
//  ServerData.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/29/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import Foundation

struct ServerData: Codable {
    
    let op : String
    let msg : String
    let servers: [Servers]
//    let servers: [Servers]
    
}
//    struct Op: Codable {
//
//    }
//    struct msg: Codable {
//
//    }
struct Servers: Codable {
    let name: String
    let ip : String
    let ovpn : String
}



