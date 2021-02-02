//
//  JwtGenerator.swift
//  PhoenixVPN
//
//  Created by MacBook Pro on 2/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import Foundation
import SwiftJWT
import UIKit

class JwtGenerator {
    
    
    func getJWT(userText: String, passtext: String, op: String) -> String {
        
        var returnValue = ""
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
           //print(uuid)
           let myHeader = Header(kid: uuid)
           let myClaims = MyClaims(username: userText, password: passtext, imei: uuid, op: op)
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
            
            returnValue = jwtString
            
           }catch {
            print("Error from jwtGenerator")
            
           }

        }
        return returnValue
    }
    
    struct MyClaims: Claims {
        let username: String
        let password: String
        let imei: String
        let op: String
    }
    
     
}



