//
//  ViewController.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/14/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit
import NetworkExtension
import MaterialComponents.MaterialBottomNavigation
import OpenVPNAdapter

class ViewController: UIViewController, UITableViewDelegate, ServerDelegate {
    

    var image: UIImage?
    let bottomNavBar = MDCBottomNavigationBar()
    @IBOutlet weak var serverTableView: UITableView!
    @IBOutlet weak var flagView: UIImageView?
    
    var index = 0
    var serverImage: UIImage?
    var svAddress : String?
    var svOvpn : String?
    var address : String?
    var user: String?
    var pass: String?

    
    var jwtforLogin : String?
    var providerManager: NETunnelProviderManager!
    
    let service = Service()
    var isConnecting = [IndexPath: Bool]()
    
    var serverTable : [Server] = []

    
    override func viewWillAppear(_ animated: Bool) {
        //flagView?.image = image
        
       // print(image)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        //print(service.server?.count)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self
        service.getVPN(endPoint: jwtforLogin!)
        serverTableView.dataSource = self
        
        print(user!)
        print(pass!)
        
        
        serverTableView.register(UINib(nibName: "ServerCell", bundle: nil), forCellReuseIdentifier: "SingleServerCell")
        serverTableView.delegate = self
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
       
        view.addSubview(bottomNavBar)
        bottomNavBar.titleVisibility = MDCBottomNavigationBarTitleVisibility.always
        bottomNavBar.alignment = MDCBottomNavigationBarAlignment.justifiedAdjacentTitles

        let homeItem = UITabBarItem(
            title: "Refresh",
            image: UIImage(named: "ic_home"),
            tag: 0)
        let messagesItem = UITabBarItem(
            title: "Network Log",
            image: UIImage(named: "ic_email"),
            tag: 1)
        let favoritesItem = UITabBarItem(
            title: "Quit",
            image: UIImage(named: "ic_favorite"),
            tag: 2)
        
        

       
        
        bottomNavBar.items = [homeItem, messagesItem, favoritesItem]
        
        bottomNavBar.selectedItemTintColor = UIColor.white
        bottomNavBar.unselectedItemTintColor = UIColor.black
        
        
        
        if bottomNavBar.selectedItem?.tag == 0 {
            print("hoise")
        }
   
        print(bottomNavBar.items[0].tag)
      
        
        let size = bottomNavBar.sizeThatFits(view.bounds.size)
      let bottomNavBarFrame = CGRect(x: 0,
        y: view.bounds.height - size.height,
        width: size.width,
        height: size.height
      )
      bottomNavBar.frame = bottomNavBarFrame
        bottomNavBar.barTintColor = UIColor.systemPurple
    }
    func updateServer(_ service: Service, serverList : [Server], login: String){
        
        print(serverList)
        self.serverTable = serverList
        print(self.serverTable)
        print(serverList.count)
        self.serverTableView.reloadData()
        
        
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
    
    func configureVPN(serverAddress: String, username: String, password: String, configData: String) {
      //guard let configData = self.readFile(path: "/Users/macbookpro/Desktop/ec2amaz-4kduhtb_openvpn_remote_access_l3.ovpn") else { return }
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
    



    @IBAction func quitButtonTapped(_ sender: UIBarButtonItem) {
        exit(0)
    }
    
    

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleServerCell", for: indexPath) as! ServerCell
        cell.serverName.text = serverTable[indexPath.row].serverName
        
//        if isConnecting[indexPath] ?? false {
//            cell.connectionButton.setTitle("Connect", for: .normal)
//        }else {
//            cell.connectionButton.setTitle("Disconnect", for: .normal)
//        }
        cell.connectionButton.layer.cornerRadius = 10
        cell.connectionButton.clipsToBounds = true
        
        cell.connectionButton.tag = indexPath.row
        cell.connectionButton.addTarget(self, action: 	#selector(self.connected(sender:)), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func connected(sender: UIButton) {
        
        
        print("sender is \(sender.tag)")
        svAddress = serverTable[sender.tag].serverIp
        let buttonPosition = sender.convert(CGPoint.zero, to: serverTableView)
        let indexPath: IndexPath? = serverTableView.indexPathForRow(at: buttonPosition)

        let cell = serverTableView.cellForRow(at: indexPath! as IndexPath) as! ServerCell

        
        
        
        if self.isConnecting[indexPath!] ?? false {
            
            if cell.connectionButton.currentTitle == "Disconnect" {
                let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to disconnect?", preferredStyle: .alert)
                // Create OK button with action handler
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    
                    self.isConnecting[indexPath!] = false
                    let jwt = JwtGenerator()
                    let jwtString = jwt.getJWT(userText: self.user!, passtext: self.pass!, op: "Disconnect")
                    print(jwtString)
                    let ptp = PacketTunnelProvider()
                    ptp.vpnReachability.stopTracking()
                    cell.connectionButton.setTitle("Connect", for: .normal)
                    print("Ok button tapped")
                })
                // Create Cancel button with action handlder
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                    print("Cancel button tapped")
                }
                
                
                //Add OK and Cancel button to an Alert object
                dialogMessage.addAction(ok)
                dialogMessage.addAction(cancel)
                // Present alert message to user
                self.present(dialogMessage, animated: true, completion: nil)
            }
                 
            } else {
                self.isConnecting[indexPath!] = true
                let jwt = JwtGenerator()
                let jwtString = jwt.getJWT(userText: self.user!, passtext: self.pass!, op: "Connect")
                print(jwtString)
                svOvpn = serverTable[sender.tag].ovpn
                self.loadProviderManager {
                    self.configureVPN(serverAddress: self.svAddress!, username: self.user!, password: self.pass!,configData: self.svOvpn!)
                }
                
                
                 cell.connectionButton.setTitle("Disconnect", for: .normal)
            }
        
        
        
        //Now change the text and background colour
        
        //cell.connectionButton.backgroundColor = UIColor.blueColor()
        print(svAddress!)
        
        
    }
    
    
}


