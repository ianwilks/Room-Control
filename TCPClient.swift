//
//  TCPClient.swift
//  Room Control App
//
//  Created by Ian on 25/08/2017.
//  Copyright © 2017 Vega. All rights reserved.
//

import Foundation
import UIKit

@objc protocol TCPStreamDelegate {
    @objc optional func tcpStreamReadComplete(buffer: String)
    @objc optional func tcpStreamEvent(event: String)
}

class TCPStream: NSObject, StreamDelegate {
    var tcpHost: String!
    var tcpPort: Int!
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var delegate: TCPStreamDelegate?
    
    var writeQueue = ""
    var writeString = ""
    var writeQueueRetries = 0
    
    var connectedFlag = false
    var bytesAvailableFlag = false
    var loggedInFlag = false
    
    var connecting = false
    
    init(tcpHost: String, tcpPort: Int){
        self.tcpHost = tcpHost
        self.tcpPort = tcpPort
        
    }
    
    func initTcpStream(){
        Stream.getStreamsToHost(withName: tcpHost, port: tcpPort, inputStream: &inputStream, outputStream: &outputStream)
        
    }
    
    func openTcpStream(){
        if !tcpHost.isEmpty{
            if inputStream != nil{
                let input = inputStream!
                input.delegate = self
                input.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                input.open()
                
            }
            if outputStream != nil{
                let output = outputStream!
                output.delegate = self
                output.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                output.open()
                
            }
        }
    }
    
    func closeTcpStream(){
        if inputStream != nil{
            let input = inputStream!
            input.close()
            input.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            
        }
        if outputStream != nil{
            let output = outputStream!
            output.close()
            output.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            
        }
    }
    
    func writeTcpStream(bufferToWrite: String){
        writeString = bufferToWrite
        //print("String sent = \(writeString)")
        if outputStream != nil{
            if outputStream?.streamStatus.rawValue != 2{
                openTcpStream()
                
            }
            if outputStream?.hasSpaceAvailable == true{
                let output = outputStream!
                if output.write(writeString, maxLength: writeString.characters.count) < 0{
                    NSLog("TCPStream writeTcpStream error sending \(writeString)")
                    
                }
                else{
                    writeQueueRetries = 0
                    
                }
            }
            else if writeQueueRetries < 10{
                writeQueue = writeQueue + bufferToWrite
                writeQueueRetries += 1
            }
            else{
                writeQueue = ""
                
            }
        }
    }
    
    // test start
    
    func sendNegotiationOne() {
        
        let cmd: [UInt8] = [0xff, 0xfc, 0x18, 0xff, 0xfc, 0x20, 0xff, 0xfc, 0x23, 0xff, 0xfc, 0x27] // Response to: ff fd 18 | ff fd 20 | ff fd 23 | ff fd 27
        
        outputStream?.write(cmd, maxLength: cmd.count)
    }
    
    func sendNegotiationTwo() {
        
        let cmd: [UInt8] = [0xff, 0xfe, 0x03, 0xff, 0xfc, 0x01, 0xff, 0xfc, 0x1f, 0xff, 0xfe, 0x05, 0xff, 0xfc, 0x21] // Response to: ff fb 03 | ff fd 01 | ff fd 1f  | ff fb 05 | ff fd 21
        
        outputStream?.write(cmd, maxLength: cmd.count)
    }
    
    func sendNegotiationThree() {
        
        let cmd: [UInt8] = [0xff, 0xfe, 0x03, 0xff, 0xfe, 0x01] // Response to: ff fb 03 | ff fb 01
        
        outputStream?.write(cmd, maxLength: cmd.count)
    }
    
    
    // test end
    
    func readTcpStream(inputStream: InputStream?){
        if inputStream != nil{
            let input = inputStream!
            var readBuffer: NSString = ""
            var readByte = [UInt8](repeating:0, count: 2048)
            while input.hasBytesAvailable{
                input.read(&readByte, maxLength: readByte.count)
                
                let tempString = NSString(bytes: readByte, length: readByte.count, encoding: String.Encoding.utf8.rawValue)
                if tempString?.length != nil{
                    readBuffer = (readBuffer as String) + (tempString! as String) as NSString
                    
                    if readBuffer.contains("*r Login successful") {
                        loggedInFlag = true
                    }
                }
            }
            if readBuffer.length > 0{
                delegate?.tcpStreamReadComplete!(buffer: readBuffer as String)
            }
        }
    }
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        var event = ""
        switch  eventCode {
        case Stream.Event.openCompleted:
            event = "openCompleted"
            connectedFlag = true
            if writeQueue != ""{
                writeTcpStream(bufferToWrite: writeQueue)
            }
            
        case Stream.Event.hasBytesAvailable:
            event = "hasBytesAvailable"
            if connectedFlag == true && loggedInFlag == false {
            
                sendNegotiationOne()
                sendNegotiationTwo()
                sendNegotiationThree()
            }
            
            if inputStream != nil{
                readTcpStream(inputStream: inputStream)
            }
            
        case Stream.Event.hasSpaceAvailable:
            event = "hasSpaceAvailable"
            if !writeQueue.isEmpty{
                writeTcpStream(bufferToWrite: writeQueue)
                writeQueue = ""
            }
            
        case Stream.Event.errorOccurred:
            event = "errorOccurred"
            print("Error occurred")
            connectedFlag = false
            loggedInFlag = false
            writeQueue = writeQueue + writeString
            closeTcpStream()
            initTcpStream()
            if !writeQueue.isEmpty && writeQueueRetries < 10{
                writeQueueRetries += 1
                openTcpStream()
            }
                
            else{
                writeQueue = ""
                NSLog("TCPStream write queue retry timeout for string: \(writeQueue)")
            }
            
        case Stream.Event.endEncountered:
            event = "endEncountered"
            print("Connection end encountered")
            connectedFlag = false
            loggedInFlag = false
            closeTcpStream()
            initTcpStream()
            if !writeQueue.isEmpty && writeQueueRetries < 10{
                writeQueueRetries += 1
                openTcpStream()
            }
                
            else{
                writeQueue = ""
                NSLog("TCPStream write queue retry timeout for string: \(writeQueue)")
                
            }
            
        case Stream.Event():
            event = "allZeros"
        default:()
        bytesAvailableFlag = false
            
        }
        
        if event != ""{
            delegate?.tcpStreamEvent!(event: event)
            
        }
    }
}

