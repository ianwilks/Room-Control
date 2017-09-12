//
//  Present View Controller.swift
//  Room Control App
//
//  Created by Ian on 07/09/2017.
//  Copyright © 2017 Vega. All rights reserved.
//

import UIKit
import Foundation


class PresentViewController: UIViewController {
    
    var codecDevice: ciscoProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        codecDevice = Global.sharedInstance.codecDevice
        codecDevice.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PresentViewController: ciscoProtocolDelegate {
    
    
}
