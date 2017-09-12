//
//  ViewController.swift
//  Room Control App
//
//  Created by Ian on 23/08/2017.
//  Copyright © 2017 Vega. All rights reserved.
//

import UIKit
import Foundation


class HomeViewController: UIViewController {
   
    var codecDevice: ciscoProtocol!
    
    var notFirstLogIn = false
    var delayTimer: Timer!
    
    
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var centreImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        codecDevice = Global.sharedInstance.codecDevice
        codecDevice.delegate = self

        if notFirstLogIn == true {
            startSpinningSingle()
        }
        else {
            startSpinning()
            codecDevice.openTcpStream()
            connectionStatusLabel.text = "Connecting to room..."
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTimer() {
        delayTimer = Timer.scheduledTimer (timeInterval: 5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
    }
    
    func runTimedCode() {
        connectionStatusLabel.text = ""
        delayTimer.invalidate()
    }
    
    func startSpinning() {
        centreImage.startRotating()
    }
    
    func stopSpinning() {
        centreImage.stopRotating()
    }
    
    func startSpinningSingle() {
        centreImage.startRotatingSingle()
    }

}

/* Extensions*/

extension HomeViewController: ciscoProtocolDelegate {
    
    
    func loginStateChange() {
        
        if codecDevice.connectionState == .connecting {
            //connectionStatusLabel.text = "Connecting to room..."
        }
        else if codecDevice.connectionState == .loggingIn {
            connectionStatusLabel.text = "Logging in..."
        }
        else if codecDevice.connectionState == .loginFailed {
            stopSpinning()
            showConnectionIncorrectCredentialsAlert()
            connectionStatusLabel.text = "Incorrect Username or Password"
        }
        else if codecDevice.connectionState == .loginSuccessful {
            connectionStatusLabel.text = ""
            notFirstLogIn = true
            stopSpinning()
            showConnectionSucceededAlert()
            if codecDevice.standbyState == .standbyOn {
            codecDevice.standbyOff()
            }
        }
        else if codecDevice.connectionState == .errorOccurred {
            stopSpinning()
            connectionStatusLabel.text = "Error!"
            createTimer()
            showConnectionLostAlert()
        }
    }
    

}

extension UIViewController {
    
    func showConnectionSucceededAlert() {
        let alert = UIAlertController(title: "Login Successful", message: "Connected to room" , preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showConnectionLostAlert() {
        let alert = UIAlertController(title: "Connection Error", message: "A Network or Authentication error has occurred, please check and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}

extension UIView {
    
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = Float(.pi * 2.0)
            animate.toValue = 0.0
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    
    func startRotatingSingle(duration: Double = 1) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = 1
            animate.fromValue = Float(.pi * 2.0)
            animate.toValue = 0.0
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
    
}









