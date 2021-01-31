//
//  ViewController.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/14/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController, UITableViewDelegate, ServerDelegate {
    

    var image: UIImage?
    @IBOutlet weak var serverTableView: UITableView!
    @IBOutlet weak var flagView: UIImageView?
    
    var index = 0
    var serverImage: UIImage?
    var svAddress : String?
    var address : String?
    var user: String?
    var pass: String?
    var providerManager: NETunnelProviderManager!
    
    let service = Service()
    
    var serverTable : [Server] = []
    
//    var serverList: [Server] = [Server(serverName: "United States", imageView: UIImage(named: "usa_flag")!,serverAddress: ""),
//                                Server(serverName: "Japan", imageView: UIImage(named: "japan")!,serverAddress: ""),
//                                Server(serverName: "Sweden", imageView: UIImage(named: "sweden")!,serverAddress: ""),
//                                Server(serverName: "Korea", imageView: UIImage(named: "korea")!,serverAddress: ""),
//                                Server(serverName: "France", imageView: UIImage(named: "fr_flag")!,serverAddress: ""),
//                                Server(serverName: "United Kingdom", imageView: UIImage(named: "uk_flag")!,serverAddress: "")]
    override func viewWillAppear(_ animated: Bool) {
        //flagView?.image = image
       // print(image)
        print(service.server?.count)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        serverTableView.dataSource = self
        service.delegate = self
        
        
        serverTableView.register(UINib(nibName: "ServerCell", bundle: nil), forCellReuseIdentifier: "SingleServerCell")
        serverTableView.delegate = self
        
        
        // Do any additional setup after loading the view.
       // print(image)
        //flagView?.image = image
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        print(index)
        //serverList[indexPath.row].imageView
        
        

        
        
    }

    
    func loadProviderManager(completion:@escaping () -> Void) {
       NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
           if error == nil {
               self.providerManager = managers?.first ?? NETunnelProviderManager()
               completion()
           }
       }
    }
    
    func configureVPN(serverAddress: String, username: String, password: String) {
      guard let configData = self.readFile(path: "/Users/macbookpro/Desktop/ec2amaz-4kduhtb_openvpn_remote_access_l3.ovpn") else { return }
      self.providerManager?.loadFromPreferences { error in
         if error == nil {
            let tunnelProtocol = NETunnelProviderProtocol()
            tunnelProtocol.username = username
            tunnelProtocol.serverAddress = serverAddress
            tunnelProtocol.providerBundleIdentifier = "com.ahasanshuvo.VPNDemo1" // bundle id of the network extension target
            tunnelProtocol.providerConfiguration = ["ovpn": configData, "username": username, "password": password]
            tunnelProtocol.disconnectOnSleep = false
            self.providerManager.protocolConfiguration = tunnelProtocol
            self.providerManager.localizedDescription = "Test-OpenVPN" // the title of the VPN profile which will appear on Settings
            self.providerManager.isEnabled = true
            self.providerManager.saveToPreferences(completionHandler: { (error) in
                  if error == nil  {
                     self.providerManager.loadFromPreferences(completionHandler: { (error) in
                         do {
                           try self.providerManager.connection.startVPNTunnel() // starts the VPN tunnel.
                         } catch let error {
                             print(error.localizedDescription)
                         }
                     })
                  }
            })
          }
       }
    }
    
    func readFile(path: String) -> Data? {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent(path)
            return try Data(contentsOf: fileURL, options: .uncached)
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    @IBAction func performUnwindSegueOperation(_ sender: UIStoryboardSegue) {
        let mainVC = sender.source as! ServerViewController
        flagView?.image = mainVC.serverImage
        address? = mainVC.svAddress!
        
    }


    @IBAction func quitButtonTapped(_ sender: UIBarButtonItem) {
        exit(0)
    }
    
    func updateServer(serverList : [Server]){
        DispatchQueue.main.async {
            self.serverTable.append(contentsOf: serverList)
            print(self.serverTable)
            print(serverList.count)
        }
        
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleServerCell", for: indexPath) as! ServerCell
        cell.serverName.text = serverTable[indexPath.row].serverName
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: 	#selector(self.switchDidChange(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    @objc func switchDidChange(_ sender: UISwitch) {
        
        print("sender is \(sender.tag)")
        svAddress = serverTable[sender.tag].serverIp
        self.loadProviderManager {
            self.configureVPN(serverAddress: self.svAddress!, username: self.user!, password: self.pass!)
        }
        
    }
    
    
}


