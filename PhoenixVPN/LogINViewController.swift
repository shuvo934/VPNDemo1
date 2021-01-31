//
//  LogINViewController.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/29/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit
import SwiftJWT



class LogINViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let service = Service()
    
    var iconClick = true
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        userName.delegate = self
        password.delegate = self
        
        userName.attributedPlaceholder = NSAttributedString(string: "User Name",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        password.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func iconClicked(_ sender: UIButton) {
        
        if(iconClick == true) {
            password.isSecureTextEntry = false
        } else {
            password.isSecureTextEntry = true
        }

        iconClick = !iconClick
    }
    @IBAction func logInButtonClicked(_ sender: UIButton) {
        
        if (userName.text == "" || password.text == "") {
            print("No username or password")
        } else {
            
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                print(uuid)
                let myHeader = Header(kid: uuid)
                let myClaims = MyClaims(username: userName.text!, password: password.text!, imei: "ccb938df67158e80", op: "login")
                var myJWT = JWT(header: myHeader, claims: myClaims)
                let privateKeypath = URL(fileURLWithPath: "/Users/macbookpro/Desktop/jwt-key.ppk")
                let publicKeypath = URL(fileURLWithPath: "/Users/macbookpro/Desktop/jwt-key.pub")
                do {
                    let privateKey : Data = try Data(contentsOf: privateKeypath, options: .alwaysMapped)
                    let jwtSigner = JWTSigner.rs256(privateKey: privateKey)
                    let signedJWT = try myJWT.sign(using: jwtSigner)
                    let publicKey : Data = try Data(contentsOf: publicKeypath, options: .alwaysMapped)
                    let jwtVerifier = JWTVerifier.rs256(publicKey: publicKey)
                    let verified = JWT<MyClaims>.verify(signedJWT, using: jwtVerifier)
                    print(verified)
                    print(myJWT)
                    
                    
                    
                    let jwtEncoder = JWTEncoder(jwtSigner: jwtSigner)
                    let jwtString = try jwtEncoder.encodeToString(myJWT)
               
    
                    print(jwtEncoder)
                    print(jwtString)
                   
                    service.getVPN(endPoint: jwtString)
                    
                   
                    
                    
                    
                } catch {
                    print("Error\(error)")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: {
                    
                    if (self.userName.text == "" || self.password.text == "") {
                        print("Error")
                    } else {
                        
                        if  (self.service.operation ?? "ok" == "ok") {
                            self.performSegue(withIdentifier: "backtoVPN", sender: self)
                        } else {
                            print("Can't Login")
                        }
                    }
                     
                })
                
                
                
            
                
                
            }
            
            
            
        }
        
        
        
        
    
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backtoVPN" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.user = userName.text!
            destinationVC.pass = password.text!
            
        }
    }
    
    struct MyClaims: Claims {
        let username: String
        let password: String
        let imei: String
        let op: String
    }
    
    



}
