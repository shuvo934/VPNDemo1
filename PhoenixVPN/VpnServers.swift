//
//  VpnServers.swift
//  PhoenixVPN
//
//  Created by MacBook Pro on 2/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import Foundation

struct VpnServers: Codable {
    let name: String
    let ip : String
    let ovpn : String
}
