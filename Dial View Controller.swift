//
//  Dial View Controller.swift
//  Room Control App
//
//  Created by Ian on 06/09/2017.
//  Copyright © 2017 Vega. All rights reserved.
//

import UIKit
import Foundation

class DialViewController: UIViewController {
    
    var codecDevice: ciscoProtocol!
    
    var dialCallNumberText = ""
    
    @IBOutlet var micMuteButton: UIButton!
    @IBOutlet var volumeMuteButton: UIButton!
    @IBOutlet var volumeLevelSlider: UISlider!
    @IBOutlet var dialCallNumberTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyBoardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        codecDevice = Global.sharedInstance.codecDevice
        codecDevice.delegate = self
        volumeLevelSlider.value = codecDevice.volumeLevelState
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func micMuteButtonPressed(_ sender: UIButton) {
        
        if codecDevice.micMuteState == .micMuted {
            codecDevice.micMuteOff()
        }
        else if codecDevice.micMuteState == .micUnmuted{
            codecDevice.micMuteOn()
        }
    }
    
    @IBAction func volumeMuteButtonPressed(_ sender: Any) {
        
        if codecDevice.volumeMuteState == .volumeMuted {
            codecDevice.volumeMuteOff()
        }
        else if codecDevice.volumeMuteState == .volumeUnmuted {
            codecDevice.volumeMuteOn()
        }
    }
    
    @IBAction func volumeSliderChanged(_ sender: UISlider) {
        codecDevice.setVolume(level: sender.value)
    }
    
    @IBAction func dialCallButtonPressed(_ sender: UIButton) {
        codecDevice.dialCall(dialNumber: dialCallNumberTextField.text!)
    }
    
    @IBAction func hangupCallButtonPressed(_ sender: UIButton) {
        codecDevice.hangupCall()
    }
    
    @IBAction func dtmfKey1(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "1")
    }
    
    @IBAction func dtmfKey2(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "2")
    }
    
    @IBAction func dtmfKey3(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "3")
    }
    
    @IBAction func dtmfKey4(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "4")
    }
    
    @IBAction func dtmfKey5(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "5")
    }
    
    @IBAction func dtmfKey6(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "6")
    }
    
    @IBAction func dtmfKey7(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "7")
    }
    
    @IBAction func dtmfKey8(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "8")
    }
    
    @IBAction func dtmfKey9(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "9")
    }
    
    @IBAction func dtmfKey0(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "0")
    }
    
    @IBAction func dtmfKeystar(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "*")
    }
    
    @IBAction func dtmfKeyhash(_ sender: UIButton) {
        codecDevice.sendDtmfTone(key: "#")
    }

}

/* Extensions */

extension DialViewController: ciscoProtocolDelegate {
    
    func micMuteStateChange() {
        micMuteButton.isSelected = codecDevice.micMuteState == .micMuted
    }
    
    func volumeMuteStateChange () {
        volumeMuteButton.isSelected = codecDevice.volumeMuteState == .volumeMuted
    }
    
    func volumeStateChange(){
        if !volumeLevelSlider.isHighlighted{
            volumeLevelSlider.value = codecDevice.volumeLevelState
        }
    }
    
}


extension UIViewController {
    

}
