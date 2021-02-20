//
//  ServerViewController.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/14/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit
import Foundation
import TrafficPolice
import SystemConfiguration.CaptiveNetwork
import NetworkExtension

class ServerViewController: UIViewController, TrafficManagerDelegate {
   
    
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var secondTimer: UILabel!
    @IBOutlet weak var minuteTimer: UILabel!
    @IBOutlet weak var hourTimer: UILabel!
    
    @IBOutlet weak var downInfo: UILabel!
    @IBOutlet weak var upInfo: UILabel!
    
    
    @IBOutlet weak var connectionInfo: UILabel!
    //    @IBOutlet weak var connStatus: UILabel!
//    @IBOutlet weak var netwokName: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
//    @IBOutlet weak var upSpeed: UILabel!
//    @IBOutlet weak var downSpeed: UILabel!
//    @IBOutlet weak var upVolume: UILabel!
//    @IBOutlet weak var downVolume: UILabel!
    
    var myTimer = Timer()
    var timerDisplayed = 0
    var minDisplayed = 0
    var hourDisplayed = 0
    
    let vc = ViewController()
    
   
    
    let status = GetConnectionInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TrafficManager.shared.delegate = self
        
       
//        backButton.layer.cornerRadius = 10
//        backButton.clipsToBounds = true
//        let ssid = getWiFiSsid() ?? "No Name"
//        print(ssid)
//        netwokName.text = ssid
        
//        let notificationObserver1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil , queue: nil) {
//           notification in
//
//           print("received NEVPNStatusDidChangeNotification")
//
//           let nevpnconn = notification.object as! NEVPNConnection
//           let status23 = nevpnconn.status
//            self.checkNEStatusok(status: status23)
//        }
        let sss = NEVPNManager.shared().connection.status
        print(sss)
        print(VpnChecker.isVpnActive())
        if VpnChecker.isVpnActive() {
            //let sss = vc.serName!
            //print(sss)
            //serverName.text = vc.serName!
            TrafficManager.shared.start()
            myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ActionTimer), userInfo: nil, repeats: true)
            connectionInfo.text = "You are connected to vpn server: \(sss.rawValue), in order to disconnect please click the button below."
            backButton.setTitle("DISCONNECT FROM THIS VPN", for: .normal)
        } else {
            
            myTimer.invalidate()
            timerDisplayed = 0
            secondTimer.text = "00"
            hourTimer.text = "00"
            minuteTimer.text = "00"
            TrafficManager.shared.reset()
        }
        

    }
    
    @objc func ActionTimer() {
        timerDisplayed += 1
        if timerDisplayed == 60 {
            secondTimer.text = "00"
            timerDisplayed = 0
            minDisplayed += 1
            if minDisplayed == 60 {
                minuteTimer.text = "00"
                minDisplayed = 0
                hourDisplayed += 1
                if hourDisplayed < 10 {
                    hourTimer.text = "0\(String(hourDisplayed))"
                }else {
                    hourTimer.text = String(hourDisplayed)
                }
                
            }else {
                if minDisplayed < 10 {
                    minuteTimer.text = "0\(String(minDisplayed))"
                }
                minuteTimer.text = String(minDisplayed)
            }
            
            
        }else {
            if timerDisplayed < 10 {
                secondTimer.text = "0\(String(minDisplayed))"
            }
            secondTimer.text = String(timerDisplayed)
        }
    }
//    func checkNEStatusok( status : NEVPNStatus ) {
//        switch status {
//        case NEVPNStatus.invalid:
//          print("NEVPNConnection: Invalid")
//            connStatus.text = "Invalid"
//        case NEVPNStatus.disconnected:
//            print("NEVPNConnection: Disconnected")
//            connStatus.text = "Disconnected"
//        case NEVPNStatus.connecting:
//          print("NEVPNConnection: Connecting")
//            connStatus.text = "Connecting"
//        case NEVPNStatus.connected:
//          print("NEVPNConnection: Connected")
//            connStatus.text = "Connected"
//        case NEVPNStatus.reasserting:
//          print("NEVPNConnection: Reasserting")
//            connStatus.text = "Reasserting"
//        case NEVPNStatus.disconnecting:
//          print("NEVPNConnection: Disconnecting")
//            connStatus.text = "Disconnecting"
//      }
//    }
    
    
    func post(summary: TrafficSummary) {
        //print(summary)
        
//        upVolume.text = "\(String(summary.wifi.data.sent/1000)) KB/s"
        downInfo.text = "\(String(summary.wifi.data.received/1000)) KB - \(String(summary.wifi.speed.received/1000)) KB/s"
        upInfo.text = "\(String(summary.wifi.data.sent/1000)) KB - \(String(summary.wifi.speed.sent/1000)) KB/s"
//        downVolume.text = "\(String(summary.wifi.data.received/1000)) KB/s"
//        upSpeed.text = "\(String(summary.wifi.speed.sent/1000)) KB/s"
//        downSpeed.text = "\(String(summary.wifi.speed.received/1000)) KB/s"
    }
    func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    

    @IBAction func backPressed(_ sender: UIButton) {
        if VpnChecker.isVpnActive() {
            //NEVPNConnection.stopVPNTunnel()
            
            let notificationObserver1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil , queue: nil) {
               notification in

               print("received NEVPNStatusDidChangeNotification")

               let nevpnconn = notification.object as! NEVPNConnection
               //let status23 = nevpnconn.status
                nevpnconn.stopVPNTunnel()
                
            }
            
//            let jwt = JwtGenerator()
//            let jwtString = jwt.getJWT(userText: vc.user!, passtext: vc.pass!, op: "disconnect")
//            status.getStatus(endPoint: jwtString)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
       
    }
    

}

struct VpnChecker {

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
