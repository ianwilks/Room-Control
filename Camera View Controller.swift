//
//  Camera View Controller.swift
//  Room Control App
//
//  Created by Ian on 06/09/2017.
//  Copyright © 2017 Vega. All rights reserved.
//

import UIKit
import Foundation

class CameraViewController: UIViewController {
    
    var codecDevice: ciscoProtocol!
    
    @IBOutlet weak var selfView: UIButton!
    
    
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
    
    
    @IBAction func selfViewButtonPressed(_ sender: UIButton) {
        if codecDevice.selfViewState == .selfViewOff {
            codecDevice.CameraSelfViewOn()
        }
        else if codecDevice.selfViewState == .selfViewOn {
            codecDevice.CameraSelfViewOff()
        }
    }
    
    @IBAction func cameraZoomPlusPressed(_ sender: UIButton) {
        codecDevice.cameraZoomPlusStop()
    }
    
    @IBAction func cameraZoomPlusReleased(_ sender: UIButton) {
        codecDevice.cameraZoomPlusStart()
    }
    
    @IBAction func cameraZoomMinusPressed(_ sender: UIButton) {
        codecDevice.cameraZoomMinusStop()
    }
    
    @IBAction func cameraZoomMinusReleased(_ sender: Any) {
        codecDevice.cameraZoomMinusStart()
    }
    
    @IBAction func cameraUpPressed(_ sender: UIButton) {
        codecDevice.cameraUpStop()
    }
    
    @IBAction func cameraUpReleased(_ sender: UIButton) {
        codecDevice.cameraUpStart()
    }
    
    @IBAction func cameraDownPressed(_ sender: UIButton) {
        codecDevice.cameraDownStop()
    }
    
    @IBAction func cameraDownReleased(_ sender: UIButton) {
        codecDevice.cameraDownStart()
    }
    
    @IBAction func cameraRightPressed(_ sender: UIButton) {
        codecDevice.cameraRightStop()
    }
    
    @IBAction func cameraRightReleased(_ sender: UIButton) {
        codecDevice.cameraRightStart()
    }
    
    @IBAction func cameraLeftPressed(_ sender: UIButton) {
        codecDevice.cameraLeftStop()
    }
    
    @IBAction func cameraLeftReleased(_ sender: UIButton) {
        codecDevice.cameraLeftStart()
    }

    
}

extension CameraViewController: ciscoProtocolDelegate {
    
    func cameraSelfViewStateChange() {
        selfView.isSelected = codecDevice.selfViewState == .selfViewOn
    }
    
    
}
