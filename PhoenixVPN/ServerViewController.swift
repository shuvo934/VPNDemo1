//
//  ServerViewController.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/14/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit

class ServerViewController: UIViewController, UITableViewDelegate {
    
    var index = 0
    var serverImage: UIImage?
    var svAddress : String?
    
    @IBOutlet weak var serverTable: UITableView!
//    var serverList: [Server] = [Server(serverName: "United States", imageView: UIImage(named: "usa_flag")!,serverAddress: ""),
//                                Server(serverName: "Japan", imageView: UIImage(named: "japan")!,serverAddress: ""),
//                                Server(serverName: "Sweden", imageView: UIImage(named: "sweden")!,serverAddress: ""),
//                                Server(serverName: "Korea", imageView: UIImage(named: "korea")!,serverAddress: ""),
//                                Server(serverName: "France", imageView: UIImage(named: "fr_flag")!,serverAddress: ""),
//                                Server(serverName: "United Kingdom", imageView: UIImage(named: "uk_flag")!,serverAddress: "")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        serverTable.dataSource = self
//        
//        serverTable.register(UINib(nibName: "ServerCell", bundle: nil), forCellReuseIdentifier: "SingleServerCell")
//        serverTable.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        print(index)
        //serverList[indexPath.row].imageView
//        serverImage = serverList[index].imageView
//        svAddress = serverList[index].serverAddress
//
//        self.performSegue(withIdentifier: "backToMenu", sender: self)
        
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "backToMenu" {
//            let destinationvc = segue.destination as! ViewController
//            serverImage = serverList[index].imageView
//            destinationvc.image = serverList[index].imageView
//            
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension ServerViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return serverList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleServerCell", for: indexPath) as! ServerCell
////        cell.serverName.text = serverList[indexPath.row].serverName
////        cell.flagImage.image = serverList[indexPath.row].imageView
//        return cell
//    }
    
    


