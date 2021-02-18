//
//  LogINViewController.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/29/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit
import SwiftJWT



class LogINViewController: UIViewController, UITextFieldDelegate, ServerDelegate{

    @IBOutlet weak var indicatorLogin: UIActivityIndicatorView!
    @IBOutlet weak var help: UILabel!
    
    @IBOutlet weak var password: UITextField!
    
    var userText = ""
    var passtext = ""
    var total = ""
    var loginOption = ""
    
    let service = Service()
    let vpnManager = VpnManager()
    
    var jwtLogin = ""
    
    var iconClick = true
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addGesture()
        indicatorLogin.hidesWhenStopped = true
        
        
        service.delegate = self
      
        password.delegate = self
        
        
        password.attributedPlaceholder = NSAttributedString(string: "Enter your PIN",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        indicatorLogin.stopAnimating()
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
    
    func updateServer(_ service: Service, serverList: [Server], login: String) {
        
        DispatchQueue.main.async {
            print(login)
            self.loginOption = login
            print(self.loginOption)
        }
        
    }
    @IBAction func logInButtonClicked(_ sender: UIButton) {
        
        
        if (password.text == "") {
            let message = "Please Inter Your PIN"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)

            // duration in seconds
            let duration: Double = 1

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
            }
        } else {
            if Reachability.isConnectedToNetwork(){
                indicatorLogin.startAnimating()
                total = password.text!
                let index = total.index(before: total.endIndex)
                let numberBeforePassword = total[index]
                print(numberBeforePassword)
                var value = 0
                do{
                    value = try Int(value: String(numberBeforePassword))
                }catch {
                    print(error)
                }
                
                
                let index1 = total.index(total.startIndex, offsetBy: value)
                let mySubstring = total.prefix(upTo: index1)
                userText = String(mySubstring)
                print(userText)
                
                let start = total.index(total.startIndex, offsetBy: value)
                let end = total.index(total.endIndex, offsetBy: -1)
                let range = start..<end
                let pass = total[range]
                passtext = String(pass)
                print(passtext)
                
                if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                    print(uuid)
                    let myHeader = Header(kid: uuid)
                    let myClaims = MyClaims(username: userText, password: passtext, imei: uuid, op: "login")
                    var myJWT = JWT(header: myHeader, claims: myClaims)
                    let path = Bundle.main.path(forResource: "jwt-key", ofType: "ppk")

                    let privateKeypath = URL(fileURLWithPath: path!)
                    let path2 = Bundle.main.path(forResource: "jwt-key", ofType: "pub")
                    
                    let publicKeypath = URL(fileURLWithPath: path2!)

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
                        
                        jwtLogin = jwtString
                       
                        service.getVPN(endPoint: jwtString)
                        
                        vpnManager.fetchVPN(endpoint: jwtString)
                        
                        
                       
                        
                        
                        
                    } catch {
                        print("Error\(error)")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                        
                        if (self.password.text == "") {
                            print("Error")
                        } else {
                            print("Login\(self.loginOption)")
                            //self.performSegue(withIdentifier: "backtoVPN", sender: self)
                            if  (self.loginOption == "ok") {
                                self.performSegue(withIdentifier: "backtoVPN", sender: self)
                            } else {
                                self.indicatorLogin.stopAnimating()
                                let message = "Incorrect PIN"
                                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                self.present(alert, animated: true)

                                // duration in seconds
                                let duration: Double = 1

                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                                    alert.dismiss(animated: true)
                                }
                                
                            }
                        }
                         
                    })
                    
                    
                    
                
                    
                    
                }
                
            }else{
                let message = "Internet Connection Not Available"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)

                // duration in seconds
                let duration: Double = 1

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
                }
            }
            
            
            
            
        }
        
      
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backtoVPN" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.user = userText
            destinationVC.pass = passtext
            destinationVC.jwtforLogin = jwtLogin
            
        }
    }
    
    func addGesture() {

           let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
           tap.numberOfTapsRequired = 1
           self.help.isUserInteractionEnabled = true
           self.help.addGestureRecognizer(tap)
       }

       @objc
       func labelTapped(_ tap: UITapGestureRecognizer) {
        performSegue(withIdentifier: "needhelp", sender: self)
       }
    
    
    struct MyClaims: Claims {
        let username: String
        let password: String
        let imei: String
        let op: String
    }
    
    



}
