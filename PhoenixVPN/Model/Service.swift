//
//  Service.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/29/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol ServerDelegate {
    func updateServer(_ service: Service, serverList: [Server], login: String)
}

class Service {
    var serverInfo : String?
    let url = "http://www.bdcorpus.com:8000/vdr/APIv01/"
    
    var operation : String?
    
    
    var delegate: ServerDelegate?

    func getVPN(endPoint: String) {
        AF.request(url + endPoint, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { [self] (responseData) in
            print("We got the Response")
            
            guard let data = responseData.data else {return}
                
                let jsonstring = String(data : data, encoding: .utf8)
               print(jsonstring!)
                
//                let str = "{\"names\": [\"Bob\", \"Tim\", \"Tina\"]}"
                let data1 = Data(jsonstring!.utf8)
            

                do {
                    
                    let jsonnew = try JSONDecoder().decode(ServerData.self, from: data1)
                    
                    self.operation = jsonnew.op
                    print(operation!)
                    var server : [Server] = []
                    for i in 0..<jsonnew.servers.count {
                        print("Server from Service: \(jsonnew.servers[i].name)")
                        server.append(Server(serverName: jsonnew.servers[i].name, serverIp: jsonnew.servers[i].ip, ovpn: jsonnew.servers[i].ovpn))
                        
                    }
                    
//                    print(operation!)
//                    print(server[0].serverName)
//                    print(server[1].serverName)
//                    print(server[0].serverIp)

                    self.delegate?.updateServer(self, serverList: server, login: operation!)
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options: .allowFragments) as? String {
                        // try to read out a string array
                     
                          print(json)
                        let jsonNew1 = json.data(using: .utf8)
                        let jsonnew = try JSONDecoder().decode(ServerData.self, from: jsonNew1!)
//                        let jsonnew = try JSONDecoder().decode(ServerData.self, from: data1)
                        
                        self.operation = jsonnew.op
                        var server : [Server] = []
                        for i in 0..<jsonnew.servers.count {
                            print("Server from Service: \(jsonnew.servers[i].name)")
                            server.append(Server(serverName: jsonnew.servers[i].name, serverIp: jsonnew.servers[i].ip, ovpn: jsonnew.servers[i].ovpn))
                            
                        }
                        
//                        print(operation!)
//                        print(server[0].serverName)
//                        print(server[1].serverName)
//                        print(server[0].serverIp)

                        self.delegate?.updateServer(self, serverList: server, login: operation!)
                        
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            

        }

    }
}
    
    


