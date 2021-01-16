//
//  ViewController.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/14/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var image: UIImage?
    @IBOutlet weak var flagView: UIImageView?
    override func viewWillAppear(_ animated: Bool) {
        //flagView?.image = image
       // print(image)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       // print(image)
        //flagView?.image = image
    }
    
    @IBAction func performUnwindSegueOperation(_ sender: UIStoryboardSegue) {
        let mainVC = sender.source as! ServerViewController
        flagView?.image = mainVC.serverImage
        
        
    }


    @IBAction func quitButtonTapped(_ sender: UIBarButtonItem) {
        exit(0)
    }
    @IBAction func connectButtonPressed(_ sender: UIButton) {
    }
}

