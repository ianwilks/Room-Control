//
//  CiscoMxSxSeriesCodecs.swift
//  Room Control App
//
//  Created by Ian on 25/08/2017.
//  Copyright © 2017 Vega. All rights reserved.
//

import Foundation

@objc protocol ciscoProtocolDelegate {
    @objc optional func micMuteStateChange()
    @objc optional func standbyStateChange()
    @objc optional func loginStateChange()
    @objc optional func volumeMuteStateChange()
    @objc optional func volumeStateChange()
    @objc optional func cameraSelfViewStateChange()
}

class ciscoProtocol {
    var tcpStream: TCPStream!
    var commands = ciscoProtocolCommands()
    
    var delegate: ciscoProtocolDelegate?
    var regCounter = 0
    var pollCounter = 0
    var deviceUsername = ""
    var devicePassword = ""
    var callId = ""
    
    public fileprivate(set) var standbyState: standbyStates = .standbyOff{
        didSet{
            if delegate != nil{
                delegate?.standbyStateChange?()
            }
        }
    }
    
    public fileprivate(set) var selfViewState: selfViewStates = .selfViewOff{
        didSet{
            if delegate != nil{
                delegate?.cameraSelfViewStateChange?()
            }
        }
    }
    
    public fileprivate(set) var connectionState: connectionStates = .loginFailed{
        didSet{
            if delegate != nil{
                delegate?.loginStateChange?()
            }
        }
    }
    
    public fileprivate(set) var micMuteState: micMuteStates = .micMuted{
        didSet{
            if delegate != nil{
                delegate?.micMuteStateChange?()
            }
        }
    }
    
    public fileprivate(set) var volumeMuteState: volumeMuteStates = .volumeMuted{
        didSet{
            if delegate != nil{
                delegate?.volumeMuteStateChange?()
            }
        }
    }
    
    public fileprivate(set) var volumeLevelState: Float = 0{ // change to Int
        didSet{
            if delegate != nil{
                delegate?.volumeStateChange?()
            }
        }
    }
    
    
    init(tcpHost: String, tcpPort: Int, username: String, password: String){
        deviceUsername = username
        devicePassword = password
        tcpStream = TCPStream(tcpHost: tcpHost, tcpPort: tcpPort)
        tcpStream.delegate = self
        tcpStream.initTcpStream()
        //openTcpStream()
    }
    
    func openTcpStream(){
        tcpStream.openTcpStream()
    }
    
    func closeTcpStream(){
        tcpStream.closeTcpStream()
    }
    
    func registerForFeedback() {
        while (regCounter <= commands.regCommands.count - 1) {
            tcpStream.writeTcpStream(bufferToWrite: commands.regCommands[regCounter])
            regCounter += 1
        }
    }
    
    func pollDevice() {
        while (pollCounter <= commands.pollCommands.count - 1) {
            tcpStream.writeTcpStream(bufferToWrite: commands.pollCommands[pollCounter])
            pollCounter += 1
        }
    }
    
    // Codec commands
    
    func sendHeartbeat() {
        tcpStream.writeTcpStream(bufferToWrite: commands.heartBeat)
    }
    
    func standbyOff() {
        tcpStream.writeTcpStream(bufferToWrite: commands.standbyOff)
        //tcpStream.writeTcpStream(bufferToWrite: commands.pollCommands[4])
    }
    
    // Audio Controls
    
    func micMuteOn() {
        tcpStream.writeTcpStream(bufferToWrite: commands.micMuteOn)
        //tcpStream.writeTcpStream(bufferToWrite: commands.pollCommands[3])
    }
    
    func micMuteOff() {
        tcpStream.writeTcpStream(bufferToWrite: commands.micMuteOff)
        //tcpStream.writeTcpStream(bufferToWrite: commands.pollCommands[3])
    }
    
    func volumeMuteOn() {
        tcpStream.writeTcpStream(bufferToWrite: commands.volumeMuteOn)
    }
    
    func volumeMuteOff() {
        tcpStream.writeTcpStream(bufferToWrite: commands.volumeMuteOff)
    }
    
    func setVolume(level: Float){
        //let scaledLevel = level.scale(minIn: 0, maxIn: 100, minOut: 0, maxOut: 100)
        let levelString = String(Int(level))
        let volumeToSend = commands.volumeSetStart + levelString + "\n"
        //print("volume level sent = \(volumeToSend)")
        tcpStream.writeTcpStream(bufferToWrite:  volumeToSend)
    }
    
    // Camera Controls
    
    func cameraZoomPlusStart() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamZoomIn)
    }
    
    func cameraZoomPlusStop() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamZoomStop)
    }
    
    func cameraZoomMinusStart() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamZoomOut)
    }
    
    func cameraZoomMinusStop() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamZoomStop)
    }
    
    func cameraUpStart() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamTiltUp)
    }
    
    func cameraUpStop() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamTiltStop)
    }
    
    func cameraDownStart() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamTiltDown)
    }
    
    func cameraDownStop() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamTiltStop)
    }
    
    func cameraLeftStart() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamPanLeft)
    }
    
    func cameraLeftStop() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamPanStop)
    }
    
    func cameraRightStart() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamPanRight)
    }
    
    func cameraRightStop() {
        tcpStream.writeTcpStream(bufferToWrite: commands.nearEndCamPanStop)
    }
    
    func dialCall(dialNumber: String) {
        let number = dialNumber
        if number != "" {
            let dialString = commands.dialStringStart + number + commands.dialStringEnd
        tcpStream.writeTcpStream(bufferToWrite: dialString)
        }
    }
    
    func hangupCall(){
        tcpStream.writeTcpStream(bufferToWrite: commands.hangupAllCallsStart + callId + "\n")
    }
    
    func CameraSelfViewOn() {
        tcpStream.writeTcpStream(bufferToWrite: commands.selfviewOn)
    }
    
    func CameraSelfViewOff() {
        tcpStream.writeTcpStream(bufferToWrite: commands.selfviewOff)
    }
    
    func getCallHistory() {
        tcpStream.writeTcpStream(bufferToWrite: commands.getCallHistory)
    }
    
    func sendDtmfTone (key: String) {
        let number = key + "\n"
        let testString = commands.dtmfStart + callId + commands.dtmfString + number
        print("DTMF String = \(testString)")
        tcpStream.writeTcpStream(bufferToWrite: commands.dtmfStart + callId + commands.dtmfString + number)
    }
}

//extension Float{
//    func scale(minIn: Float, maxIn: Float, minOut: Float, maxOut: Float) -> Float{
//        //range check
//        if (minIn == maxIn){
//            NSLog("Warning: Zero input range")
//            return 0
//        }
//        
//        if (minOut == maxOut){
//            NSLog("Warning: Zero output range")
//            return 0
//        }
//        
//        //check reversed input range
//        var reverseInput = false
//        
//        if (maxIn != minIn){
//            reverseInput = true
//        }
//        
//        //check reversed output range
//        var reverseOutput = false
//        
//        if (maxOut != minOut){
//            reverseOutput = true
//        }
//        
//        var portion = (self - minIn) * (maxOut - minOut) / (maxIn - minIn)
//        if (reverseInput){
//            portion = (maxIn - self) * (maxOut - minOut) / (maxIn - minIn)
//        }
//        
//        var result = portion + minOut
//        if (reverseOutput){
//            result = maxOut - portion
//        }
//        
//        return result
//    }
//}


extension ciscoProtocol: TCPStreamDelegate {
    
    func tcpStreamReadComplete(buffer: String) {
        
        if buffer.contains("login:") {
            connectionState = connectionStates.loggingIn
            tcpStream.writeTcpStream(bufferToWrite: deviceUsername)
        }
            
        else if buffer.contains("Password:") {
            tcpStream.writeTcpStream(bufferToWrite: devicePassword)
        }
            
        else if buffer.contains("*r Login successful") {
            connectionState = connectionStates.loginSuccessful
            registerForFeedback()
            if (regCounter == commands.regCommands.count) {
                pollDevice()
            }
            if (pollCounter == commands.pollCommands.count) {
                standbyOff()
                //getCallHistory()
                
            }
        }
            
        else if buffer.contains("Login incorrect") {
            connectionState = connectionStates.loginFailed
        }
            
            // these are responses to status requests
            
        else if buffer.contains("*s Conference Presentation Mode: Off") {
        }
        else if buffer.contains("*s Conference Presentation Mode: On") {
        }
        else if buffer.contains("*s Video Selfview Mode: Off") {
            selfViewState = selfViewStates.selfViewOff
        }
        else if buffer.contains("*s Video Selfview Mode: On") {
            selfViewState = selfViewStates.selfViewOn
        }
        else if buffer.contains("*s Standby State: Standby") {
            standbyState = standbyStates.standbyOn
        }
        else if buffer.contains("*s Standby State: Off") {
            standbyState = standbyStates.standbyOff
        }
        else if buffer.contains("*s Audio Microphones Mute: On") {
            micMuteState = micMuteStates.micMuted
        }
        else if buffer.contains("*s Audio Microphones Mute: Off") {
            micMuteState = micMuteStates.micUnmuted
        }
        else if buffer.contains("*s Audio VolumeMute: Off") {
            volumeMuteState = volumeMuteStates.volumeUnmuted
        }
        else if buffer.contains("*s Audio VolumeMute: On") {
            volumeMuteState = volumeMuteStates.volumeMuted
        }
        else if buffer.contains("*s Call") {
            var callData = buffer.components(separatedBy: " ")
            let decimals = ("0123456789".characters)
            let filteredString = String(callData[2].characters.filter{decimals.contains($0)})
            print("filtered string = \(filteredString)")
            if filteredString != "" {
                callId = filteredString
                }
        }
        
//        else if buffer.contains("*s Audio Volume: ") {
//            var volumeLevelData = buffer.components(separatedBy: "\r\n")
//            volumeLevelData = volumeLevelData[0].components(separatedBy: " ")
//            if let volumeLevel = Float(volumeLevelData[3]) {
//                print("volume = \(volumeLevel)")
//                volumeLevelState = volumeLevel
//            }
//        }
        
    }
    
    func tcpStreamEvent(event: String) {
        switch event {
        case "openCompleted":
            connectionState = connectionStates.connecting
            break
        case "errorOccurred":
            connectionState = connectionStates.errorOccurred
            break
        case "endEncountered":
            connectionState = connectionStates.connectionClosed
            break
        default:
            ()
        }
    }
}

extension ciscoProtocol {
    enum standbyStates {
        case standbyOn
        case standbyOff
    }
    
    enum connectionStates {
        case loginSuccessful
        case loginFailed
        case errorOccurred
        case connectionClosed
        case connecting
        case loggingIn
    }
    
    enum micMuteStates {
        case micMuted
        case micUnmuted
    }
    
    enum selfViewStates {
        case selfViewOn
        case selfViewOff
    }
    
    enum volumeMuteStates {
        case volumeMuted
        case volumeUnmuted
    }
}


class ciscoProtocolCommands {
    
    // Feedback registrations
    let regCommands = [
        //"echo off\n",
        "xFeedback deregisterall\n",
        "xFeedback register Status/Audio/Volume\n",
        "xFeedback register Status/Audio/VolumeMute\n",
        "xFeedback register Status/Audio/Microphones/Mute\n",
        "xFeedback register Status/Video/Selfview\n",
        "xFeedback register Status/Conference/Presentation/LocalSource\n",
        "xFeedback register Status/Conference/Presentation/Mode\n",
        "xFeedback register Status/Call\n",
        "xFeedback register Status/Standby/State\n"
        //"xFeedback list\n"
    ]
    
    // Status requests
    let pollCommands = [
        "xStatus Conference Presentation Mode\n",
        "xStatus Audio Volume\n",
        "xStatus Audio VolumeMute\n",
        "xStatus Audio Microphones Mute\n",
        "xStatus Standby State\n",
        "xStatus Video Selfview Mode\n",
        "xStatus Call\n"
    ]
    
    // Commands
    let micMuteOn = "xCommand Audio Microphones Mute\n"
    let micMuteOff = "xCommand Audio Microphones Unmute\n"
    let standbyOn = "xCommand Standby Activate\n"
    let standbyOff = "xCommand Standby Deactivate\n"
    let selfviewOn = "xCommand Video Selfview Set Mode: On\n"
    let selfviewOff = "xCommand Video Selfview Set Mode: Off\n"
    
    let nearEndCamTiltUp = "xCommand Camera Ramp CameraId: 1 Tilt: Up\n"
    let nearEndCamTiltDown = "xCommand Camera Ramp CameraId: 1 Tilt: Down\n"
    let nearEndCamTiltStop = "xCommand Camera Ramp CameraId: 1 Tilt: Stop\n"
    let nearEndCamPanLeft = "xCommand Camera Ramp CameraId: 1 Pan: Left\n"
    let nearEndCamPanRight = "xCommand Camera Ramp CameraId: 1 Pan: Right\n"
    let nearEndCamPanStop = "xCommand Camera Ramp CameraId: 1 Pan: Stop\n"
    let nearEndCamZoomIn = "xCommand Camera Ramp CameraId: 1 Zoom: In\n"
    let nearEndCamZoomOut = "xCommand Camera Ramp CameraId: 1 Zoom: Out\n"
    let nearEndCamZoomStop = "xCommand Camera Ramp CameraId: 1 Zoom: Stop\n"
    
    let nearEndPresentStart = "xCommand Presentation Start PresentationSource: 1 SendingMode: LocalRemote\n"
    let nearEndPresentStop = "xCommand Presentation Stop\n"
    
    let volumeMuteOn = "xCommand Audio Volume Mute\n"
    let volumeMuteOff = "xCommand Audio Volume Unmute\n"
    let volumeIncrease = "xCommand Audio Volume Increase\n"
    let volumeDecrease = "xCommand Audio Volume Decrease\n"
    
    // xCommand Dial Number: 192.168.12.200 Sip 3072 Video\n
    
    let dialStringStart = "xCommand Dial Number: "
    let dialStringEnd = " Protocol: Sip CallRate: 3072 CallType: Video\n"
    
    let hangupAllCallsStart = "xCommand Call Disconnect CallId: "
    let callStatus = "xStatus Call\n"
    
    let getCallHistory = "xCommand CallHistory Recents Filter: Placed Limit: 5 DetailLevel: Basic Order: OccurrenceTime\n"
    
    // xCommand Call DTMFSend CallId: 7 DTMFString: 1234\n
    
    let dtmfString = " DTMFString: "
    let dtmfStart = "xCommand Call DTMFSend CallId: "
    
    let volumeSetStart = "xCommand Audio Volume Set Level: "
    
    let heartBeat = "xStatus SystemUnit ProductPlatform\n"
}

