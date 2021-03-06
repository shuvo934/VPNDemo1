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
    
    @IBOutlet weak var serverTableView: UITableView!
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var index = 0
    public var serName: String?
    var svAddress : String?
    var svOvpn : String?
    var address : String?
    var user: String?
    var pass: String?
    var disconnect = false
    
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
        indicatorView.isHidden = true
        indicator.hidesWhenStopped = true
        service.delegate = self
        service.getVPN(endPoint: jwtforLogin!)
        serverTableView.dataSource = self
        
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil , queue: nil) {
           notification in

           print("received NEVPNStatusDidChangeNotification")

           let nevpnconn = notification.object as! NEVPNConnection
           let status23 = nevpnconn.status
            self.checkNEStatus(status: status23)
        }
        
        print(user!)
        print(pass!)
        
        
        serverTableView.register(UINib(nibName: "ServerCell", bundle: nil), forCellReuseIdentifier: "SingleServerCell")
        serverTableView.delegate = self
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func checkNEStatus( status : NEVPNStatus ) {
        switch status {
        case NEVPNStatus.invalid:
          print("NEVPNConnection: Invalid")
        case NEVPNStatus.disconnected:
            print("NEVPNConnection: Disconnected")
        case NEVPNStatus.connecting:
          print("NEVPNConnection: Connecting")
            
            
            let message = "Connecting"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)

            // duration in seconds
            let duration: Double = 1

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
        }
            indicatorView.isHidden = false
            indicator.startAnimating()
        case NEVPNStatus.connected:
          print("NEVPNConnection: Connected")
            
            
            let message = "Connected"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)

            // duration in seconds
            let duration: Double = 1

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
        }
            indicatorView.isHidden = true
            indicator.stopAnimating()
        case NEVPNStatus.reasserting:
          print("NEVPNConnection: Reasserting")
        case NEVPNStatus.disconnecting:
          print("NEVPNConnection: Disconnecting")
            indicatorView.isHidden = true
            indicator.stopAnimating()
            let message = "VPN Could Not Connect"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)

            // duration in seconds
            let duration: Double = 1

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
        }
      }
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
    
    func configureVPN(serverAddress: String, username: String, password: String, configData: Data) {
      //guard let configData = self.readFile(path: "/Users/macbookpro/Desktop/ec2amaz-4kduhtb_openvpn_remote_access_l3.ovpn") else { return }
      self.providerManager?.loadFromPreferences { error in
         if error == nil {
            let tunnelProtocol = NETunnelProviderProtocol()
            tunnelProtocol.username = username
            tunnelProtocol.serverAddress = serverAddress
            //tunnelProtocol.passwordReference
            tunnelProtocol.providerBundleIdentifier = "com.ahasanshuvo.VOXEN.VPNTunnel" // bundle id of the network extension target
            tunnelProtocol.providerConfiguration = ["ovpn": configData, "username": username, "password": password]
            tunnelProtocol.disconnectOnSleep = false
            self.providerManager.protocolConfiguration = tunnelProtocol
            self.providerManager.localizedDescription = "VOXEN" // the title of the VPN profile which will appear on Settings
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
    


    @IBAction func networkLogPressed(_ sender: UIButton) {
        
//        print(serName)
//        print(user)
//        print(pass)
        performSegue(withIdentifier: "networkLog", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "networkLog" {
            let destinationVC = segue.destination as! ServerViewController
            destinationVC.serv = serName ?? "No Server"
            destinationVC.user = user ?? "No user"
            destinationVC.pass = pass ?? "No pass"
            destinationVC.providerManager = providerManager
        }
    }
    
   
    @IBAction func quit(_ sender: UIButton) {
        
        
            let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure want to LogOut?", preferredStyle: .alert)
            // Create OK button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                
                if VpnNewChecker.isVpnActive() {
                    self.providerManager.connection.stopVPNTunnel()
                    let jwt = JwtGenerator()
                    let jwtString = jwt.getJWT(userText: self.user!, passtext: self.pass!, op: "disconnect")
                    let status = GetConnectionInfo()
                    status.getStatus(endPoint: jwtString)
                    _ = self.navigationController?.popToRootViewController(animated: true)
                } else {
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
                
                //print(jwtString)
               
                
                
                let message = "LOG OUT!"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)

                // duration in seconds
                let duration: Double = 1

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
            }
                
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
    
    
    @IBAction func refresh(_ sender: UIButton) {
        service.getVPN(endPoint: jwtforLogin!)
        self.serverTableView.reloadData()
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
        
        cell.connectionButton.addTarget(self, action: #selector(self.connected(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    @objc func connected(sender: UIButton) {
        
        let taggger = sender.tag
        
        
        
        print("sender is \(sender.tag)")
        svAddress = serverTable[sender.tag].serverIp
        let buttonPosition = sender.convert(CGPoint.zero, to: serverTableView)
        let indexPath: IndexPath? = serverTableView.indexPathForRow(at: buttonPosition)

        let cell = serverTableView.cellForRow(at: indexPath! as IndexPath) as! ServerCell

        
        
        
        if self.isConnecting[indexPath!] ?? false {
            
            if cell.connectionButton.currentTitle == "Disconnect" {
                let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure want to disconnect?", preferredStyle: .alert)
                // Create OK button with action handler
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    
                    self.isConnecting[indexPath!] = false
                    
                    //print(jwtString)
                    let status = GetConnectionInfo()
                    
                    self.providerManager.connection.stopVPNTunnel()
                    
                    let jwt = JwtGenerator()
                    let jwtString = jwt.getJWT(userText: self.user!, passtext: self.pass!, op: "disconnect")
                    status.getStatus(endPoint: jwtString)
                    
                    cell.connectionButton.setTitle("Connect", for: .normal)
                    self.disconnect = false
                    
                
                    self.serverTableView.reloadData()
                    self.indicatorView.isHidden = true
                    self.indicator.stopAnimating()
                    print("Ok button tapped")
                    
                    let message = "Disconnected!"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    self.present(alert, animated: true)

                    // duration in seconds
                    let duration: Double = 1

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                        alert.dismiss(animated: true)
                }
                    
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
                 
            } else if sender.tag == taggger && cell.connectionButton.currentTitle == "Connect" && disconnect == false  {
                disconnect = true
                self.isConnecting[indexPath!] = true
                
                
                svOvpn = serverTable[sender.tag].ovpn
                serName = serverTable[sender.tag].serverName
                print(serName ?? "NO")
                //let data = Data(svOvpn!.utf8)
                let ovpnFile = "server.ovpn"
                let text = svOvpn!
                var data : Data = Data("DDD".utf8)
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

                    let fileURL = dir.appendingPathComponent(ovpnFile)

                    //writing
                    do {
                        try text.write(to: fileURL, atomically: true, encoding: .utf8)
//                        let input = try String(contentsOf: fileURL)
//                                    print(input)
                    }
                    catch {print(error.localizedDescription)}
                    do {
                            let text2 = try Data(contentsOf: fileURL, options: .uncached)
                            data = text2
                        
                        }
                        catch {print(error.localizedDescription)}
                    }
                
//                guard
//                        let configurationFileURL = Bundle.main.url(forResource: "voxen2", withExtension: "ovpn"),
//                        let configurationFileContent = try? Data(contentsOf: configurationFileURL)
//
//                    else {
//                        fatalError()
//                    }
                
                
//                guard
//                        let configurationFileURL = Bundle.main.url(forResource: "USA_freeopenvpn_udp", withExtension: "ovpn"),
//                        let configurationFileContent = try? Data(contentsOf: configurationFileURL)
//                    else {
//                        fatalError()
//                    }
                self.loadProviderManager {
                   self.configureVPN(serverAddress: self.svAddress!, username: self.user!, password: self.pass!,configData: data)
//                   self.configureVPN(serverAddress: "", username: "freeopenvpn", password: "508918325",configData: configurationFileContent)
//                    self.configureVPN(serverAddress: "server1.freevpn.me", username: "freevpn.me", password: "vf4F8y6NB3t",configData: configurationFileContent)
                }
                
                let jwt = JwtGenerator()
                let jwtString = jwt.getJWT(userText: self.user!, passtext: self.pass!, op: "connect")
                print(jwtString)
                let status = GetConnectionInfo()
                status.getStatus(endPoint: jwtString)
                
                
                
                 cell.connectionButton.setTitle("Disconnect", for: .normal)
                
                guard let indexpath = serverTableView.indexPath(for: cell) else {
                    
                    return
                }
                print(indexpath.row)
                

                self.serverTableView.reloadData()
            } else {
                let message = "Please Disconnect First!!"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)

                // duration in seconds
                let duration: Double = 1

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
            }
            }
        
        
        
        //Now change the text and background colour
        
        //cell.connectionButton.backgroundColor = UIColor.blueColor()
        print(svAddress!)
        
        
    }
    
    
}

struct VpnNewChecker {

    private static let vpnProtocolsKeysIdentifiers = [
        "tap", "tun", "ppp", "ipsec", "utun"
    ]

    static func isVpnActive() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
            let allKeys = keys.allKeys as? [String] else { return false }

        // Checking for tunneling protocols in the keys
        for key in allKeys {
            for protocolId in vpnProtocolsKeysIdentifiers
                where key.starts(with: protocolId) {
                // I use start(with:), so I can cover also `ipsec4`, `ppp0`, `utun0` etc...
                return true
            }
        }
        return false
    }
}


