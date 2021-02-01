//
//  ServerModel.swift
//  PhoenixVPN
//
//  Created by MacBook Pro on 2/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import Foundation

struct ServerModel {
    let operationStatus: String
    let message : String
    let serverinfo : [ServerInfo]
}
struct ServerInfo {
    let serverName: String
    let serverIP: String
    let serverOvpn: String
}
