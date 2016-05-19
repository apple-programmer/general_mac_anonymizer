//
//  Tor functions.swift
//  MKO project
//
//  Created by Roman Nikitin on 07.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Foundation
import Cocoa
import CocoaAsyncSocket

func launchTorImpr(hashedPassword hash : String) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
        () -> Void in
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = (["-c", "/usr/local/bin/tor HashedControlPassword \(hash)"])
        task.currentDirectoryPath = "~/"
        
        let pipe = NSPipe()
        let error = NSPipe()
        
        task.standardOutput = pipe
        task.standardError = error
        
        let handle = pipe.fileHandleForReading
        let errHandle = error.fileHandleForReading
        errHandle.waitForDataInBackgroundAndNotify()
        
        
        isTorLaunched = true
        
        var observer : NSObjectProtocol!
        observer = NSNotificationCenter().addObserverForName(NSTaskDidTerminateNotification, object: nil, queue: nil) {
            notification -> Void in
            let data = errHandle.availableData
            if data.length > 0 {
                if let errorStr = String(data: data, encoding: NSUTF8StringEncoding) {
                    print("Tor error accured : \(errorStr)")
                    isTorLaunched = false
                }
            }
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        
        printToGUI("Launching TOR:")
        if isTorLaunched {
            task.launch()
            
            var data = NSData()
            
            while task.running && isTorLaunched {
                data = handle.availableData
                let output = String(data: data, encoding: NSUTF8StringEncoding)!
                
                print("Tor output : \(output)")
                printToGUI(output)
                
                if output.hasSuffix("Done\n") {
                    printToGUI("TOR launched successfully!")
                    readyToGO = true
                    break
                }
            }
            
            while isTorLaunched {
                if !task.running {
                    break
                }
                NSThread.sleepForTimeInterval(0.5)
            }
            task.terminate()
            print("Tor terminated")
            printToGUI("Tor terminated")
            NSNotificationCenter().postNotificationName("TorTerminated", object: nil)
        }
    }
}

class Connection : GCDAsyncSocketDelegate {
    let host : String?
    let port : UInt16?
    var socket : GCDAsyncSocket?
    
    required init(host _host : String, port _port : UInt16) {
        self.host = _host
        self.port = _port
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    func requestIdentity() -> Bool {
        do {
            try socket?.connectToHost(host!, onPort: port!, withTimeout: NSTimeInterval(2.0))
        }
        catch {
            print("Error \(error as NSError) accured while connecting to host \(host) on port \(port)")
            return false
        }
        return true
    }
    
    @objc func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        if err.userInfo["NSLocalizedDescription"] as? String == "Connection refused" {
            print("Tor is not launched!")
            initTor()
        }
    }
    
    @objc func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        let response = String(data: data, encoding: NSUTF8StringEncoding)
        print("Got response : \(response)")
    }
    
    @objc func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("Connected to host \(host) on port \(port)")
        var request = "AUTHENTICATE \"\(NSUserDefaults.standardUserDefaults().objectForKey("torControlPassword") as! String)\"\n"
        var data = request.dataUsingEncoding(NSUTF8StringEncoding)
        socket!.writeData(data, withTimeout: -1.0, tag: 0)
        socket!.readDataWithTimeout(-1.0, tag: 0)
        request = "SIGNAL NEWNYM\n"
        data = request.dataUsingEncoding(NSUTF8StringEncoding)
        socket!.writeData(data, withTimeout: -1.0, tag: 0)
        socket!.readDataWithTimeout(-1.0, tag: 0)
        request = "QUIT\n"
        data = request.dataUsingEncoding(NSUTF8StringEncoding)
        socket!.writeData(data, withTimeout: -1.0, tag: 0)
        printToGUI("Got new identity")
    }
    
    deinit {
        socket?.delegate = nil
    }
}

func installTor() {
    if fileExists(pathToFile: "\(NSFileManager.defaultManager().currentDirectoryPath)//.pw.sh") {
        runCommand(command: "\(askpass) sudo -Ak brew install tor")
    }
    else {
        getPassword()
        installTor()
    }
}

func isTorInstalled() -> Bool {
    let arr = runCommand(command: "command -v /usr/local/bin/tor")
    return !arr.isEmpty
}

func configureTor() {
    let configPath = "/usr/local/etc/tor/torrc"
    let newConfigPath = NSBundle.mainBundle().pathForResource("torConfig", ofType: "txt")
    runCommand(command: "\(askpass) sudo -Ak rm \(configPath)")
    do {
        let content = try String(contentsOfFile: newConfigPath!, encoding: NSUTF8StringEncoding)
        try content.writeToFile(configPath, atomically: true, encoding: NSUTF8StringEncoding)
    }
    catch {
        print("Error \(error as NSError) while configuring Tor")
    }
    
}

func generateHash() -> String {
    let passwd = randomString()
    print("Session password : \(passwd)")
    NSUserDefaults.standardUserDefaults().setObject(passwd, forKey: "torControlPassword")
    let output = runCommand(command: "/usr/local/bin/tor --hash-password \(passwd)").componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    for line in output {
        if line.hasPrefix("16:") {
            return line
        }
    }
    return generateHash()
}

func initTor() {
    if !isTorInstalled() {
        installTor()
    }
    configureTor()
    let hash = generateHash()
    launchTorImpr(hashedPassword: hash)
}