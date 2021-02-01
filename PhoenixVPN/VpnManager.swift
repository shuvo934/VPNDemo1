//
//  VpnManager.swift
//  PhoenixVPN
//
//  Created by MacBook Pro on 2/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import Foundation

struct VpnManager{
    let url = "http://www.bdcorpus.com:8000/vdr/APIv01/"
    
    func fetchVPN(endpoint: String) {
        let urlString = url + endpoint
        performRequest(urlStr: urlString)
    }
    
    func performRequest(urlStr: String) {
        if let url = URL(string: urlStr) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let dataString = String(data: safeData, encoding: .utf8){
                        let data1 = Data(dataString.utf8)
                        self.parseJSON(serverData: data1)
                    }
                    
                    
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(serverData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ServerData.self, from: serverData)
            
            _ = decodedData.op
            for i in 0..<decodedData.servers.count {
                let serverName = decodedData.servers[i].name
                print("Server from VPN: \(serverName)")
            }
            //print(decodedData.op)
        } catch {
            print(error)
        }
        
    }
    
}
