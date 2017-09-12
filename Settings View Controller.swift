//
//  Settings View Controller.swift
//  Room Control App
//
//  Created by Ian on 06/09/2017.
//  Copyright © 2017 Vega. All rights reserved.
//

import UIKit
import Foundation


class SettingsViewController: UIViewController {
    
    var codecDevice: ciscoProtocol!
    

    @IBOutlet var userTextFieldRoomName: UITextField!
    @IBOutlet var userTextFieldIpAddress: UITextField!
    @IBOutlet var userTextFieldPortNo: UITextField!
    @IBOutlet var userTextFieldUsername: UITextField!
    @IBOutlet var userTextFieldPassword: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyBoardWhenTappedAround()
        loadDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        codecDevice = Global.sharedInstance.codecDevice
        codecDevice.delegate = self
    }
    
    @IBAction func userSettingsPasswordShowPressed(_ sender: UIButton) {
        userTextFieldPassword.isSecureTextEntry = false
    }
    
    @IBAction func userSettingsPasswordEyeReleased(_ sender: UIButton) {
        userTextFieldPassword.isSecureTextEntry = true
    }
    
    @IBAction func userTextFieldSettingsSavePressed(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        
        if userTextFieldIpAddress.text != "" && userTextFieldPortNo.text != "" && userTextFieldUsername.text != "" && userTextFieldPassword.text != "" {
            
            defaults.set(userTextFieldRoomName.text, forKey: "RoomName")
            defaults.set(userTextFieldIpAddress.text, forKey: "IPAddress")
            defaults.set(userTextFieldPortNo.text, forKey: "PortNo")
            defaults.set(userTextFieldUsername.text, forKey: "Username")
            defaults.set(userTextFieldPassword.text, forKey: "Password")
            defaults.synchronize()
            
            showSettingsSuccessAlert()
            
        }
        else {
            showSettingsFailAlert()
        }
    }
    
    
    func loadDefaults() {
        
        let defaults = UserDefaults.standard
        userTextFieldRoomName.text = (defaults.object(forKey: "RoomName") as! String)
        userTextFieldIpAddress.text = (defaults.object(forKey: "IPAddress") as! String)
        userTextFieldPortNo.text = (defaults.object(forKey: "PortNo") as! String)
        userTextFieldUsername.text = (defaults.object(forKey: "Username") as! String)
        userTextFieldPassword.text = (defaults.object(forKey: "Password") as! String)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

/* Extensions */

extension SettingsViewController: ciscoProtocolDelegate {
    
    func settingsLoginStateChange() {
        
    }
    
}

extension UIViewController {
    
    func hideKeyBoardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showSettingsSuccessAlert() {
        let alert = UIAlertController(title: "Success!", message: "Connection Settings Saved", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSettingsFailAlert() {
        let alert = UIAlertController(title: "Whoops!", message: "Please complete all mandatory fields", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showConnectionIncorrectCredentialsAlert() {
        let alert = UIAlertController(title: "Login Failed", message: "Please check the Username and Password are correct", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    

    
}


