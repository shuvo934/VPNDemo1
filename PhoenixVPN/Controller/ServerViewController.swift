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

class ServerViewController: UIViewController, TrafficManagerDelegate {
   
    
    
    @IBOutlet weak var netwokName: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var upSpeed: UILabel!
    @IBOutlet weak var downSpeed: UILabel!
    @IBOutlet weak var upVolume: UILabel!
    @IBOutlet weak var downVolume: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        TrafficManager.shared.delegate = self
        TrafficManager.shared.start()
        backButton.layer.cornerRadius = 10
        backButton.clipsToBounds = true
        let ssid = getWiFiSsid() ?? "No Name"
        print(ssid)
        netwokName.text = ssid
        

    }
    
    func post(summary: TrafficSummary) {
        print(summary)
        upVolume.text = "\(String(summary.wifi.data.sent/1000)) KB/s"
        downVolume.text = "\(String(summary.wifi.data.received/1000)) KB/s"
        upSpeed.text = "\(String(summary.wifi.speed.sent/1000)) KB/s"
        downSpeed.text = "\(String(summary.wifi.speed.received/1000)) KB/s"
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
        self.dismiss(animated: true, completion: nil)
    }
    

}
