//
//  ServerViewController.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/14/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit

class ServerViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = 10
        backButton.clipsToBounds = true
        

    }
    

    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
