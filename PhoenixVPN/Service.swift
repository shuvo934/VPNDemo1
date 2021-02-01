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
            do {
                
                let jsonstring = String(data : data, encoding: .utf8)
               print(jsonstring!)
                
//                let str = "{\"names\": [\"Bob\", \"Tim\", \"Tina\"]}"
                let data1 = Data(jsonstring!.utf8)

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options: .allowFragments) as? String {
                        // try to read out a string array
                     
                          print(json)
                        let jsonNew1 = json.data(using: .utf8)
                        let jsonnew = try JSONDecoder().decode(ServerData.self, from: jsonNew1!)
                        
                        self.operation = jsonnew.op
                        var server : [Server] = []
                        for i in 0..<jsonnew.servers.count {
                            print("Server from Service: \(jsonnew.servers[i].name)")
                            server.append(Server(serverName: jsonnew.servers[i].name, serverIp: jsonnew.servers[i].ip, ovpn: jsonnew.servers[i].ovpn))
                            
                        }
                        
//                         let server = [Server(serverName: jsonnew.servers[0].name, serverIp: jsonnew.servers[0].ip, ovpn: jsonnew.servers[0].ovpn),
//                                       Server(serverName: jsonnew.servers[1].name, serverIp: jsonnew.servers[1].ip, ovpn: jsonnew.servers[1].ovpn)]
                        print(operation!)
                        print(server[0].serverName)
                        print(server[1].serverName)
                        print(server[0].serverIp)
                        
                        //let newServer = Server(serverName: <#T##String#>, serverIp: <#T##String#>, ovpn: <#T##String#>)
                        
                        
                        self.delegate?.updateServer(self, serverList: server, login: operation!)
                        
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            
            } catch {
                print("Error\(error)")
            }

        }
//        AF.download(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil, to: nil)
    }
}
    
    


