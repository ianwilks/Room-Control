//
//  Global Settings.swift
//  Room Control App
//
//  Created by Ian on 25/08/2017.
//  Copyright © 2017 Vega. All rights reserved.
//

import Foundation

class Global {
    static let sharedInstance = Global()
    let codecDevice: ciscoProtocol
    
    private init() {
        
        var host = ""
        var portIn = ""
        var username = ""
        var password = ""
        var port = 0
            
        let defaults = UserDefaults.standard
            
        host = (defaults.object(forKey: "IPAddress") as! String)
        portIn = (defaults.object(forKey: "PortNo") as! String)
        port = Int(portIn)!
        username = (defaults.object(forKey: "Username") as! String) + "\n"
        password = (defaults.object(forKey: "Password") as! String) + "\n"
        
        codecDevice = ciscoProtocol(tcpHost: host, tcpPort: port, username: username, password: password)
    }
}
