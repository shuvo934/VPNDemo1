//
//  NeedHelpViewController.swift
//  PhoenixVPN
//
//  Created by MacBook Pro on 2/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit
import MessageUI

class NeedHelpViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var mailText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addGesture()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addGesture() {

           let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
           tap.numberOfTapsRequired = 1
           self.mailText.isUserInteractionEnabled = true
           self.mailText.addGestureRecognizer(tap)
       }

       @objc
       func labelTapped(_ tap: UITapGestureRecognizer) {

        let recipientEmail = mailText.text!
        //let email = "foo@bar.com"
        if let url = URL(string: "mailto:\(recipientEmail)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    
       }
                
               
                
        
}


