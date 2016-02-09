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

func launchTor(hashedPassword hash : String) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = (["-c", "/usr/local/bin/tor HashedControlPassword \(hash)"])
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        let handle = pipe.fileHandleForReading
        handle.waitForDataInBackgroundAndNotify()
        
        let errPipe = NSPipe()
        task.standardError = errPipe
        let errHandle = errPipe.fileHandleForReading
        errHandle.waitForDataInBackgroundAndNotify()
        
//        var startObserver : NSObjectProtocol!
//        startObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: nil, queue: nil) { notification -> Void in
//            let data = handle.availableData
//            if data.length > 0 {
//                if let output = String(data: data, encoding: NSUTF8StringEncoding) {
//                    print("Output : \(output)")
//                }
//            }
//            else {
//                print("EOF on stdout")
//                NSNotificationCenter.defaultCenter().removeObserver(startObserver)
//            }
//        }
        
        var endObserver : NSObjectProtocol!
        endObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSTaskDidTerminateNotification, object: nil, queue: nil) {
            notification -> Void in
            print("Task \"Tor\" terminated with code \(task.terminationStatus)")
            NSNotificationCenter.defaultCenter().removeObserver(endObserver)
        }
        
        var errObserver : NSObjectProtocol!
        errObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSTaskDidTerminateNotification, object: nil, queue: nil) {
            notification -> Void in
            let data = errHandle.availableData
            if (data.length > 0) {
                if let output = String(data: data, encoding: NSUTF8StringEncoding) {
                    print("Error : \(output)")
                    
                    NSNotificationCenter.defaultCenter().removeObserver(errObserver)
                }
            }
        }
        
        let terminateObserver : NSObjectProtocol!
        terminateObserver = NSNotificationCenter.defaultCenter().addObserverForName("AppTerminates", object: nil, queue: nil) {
            notification -> Void in
            print("Terminating...")
            task.terminate()
            
            runCommand(command: "\(askpass) sudo -Ak killall privoxy", waitForCompletion: false)
            
            print("privoxy terminated")
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath("\(NSFileManager.defaultManager().currentDirectoryPath)//.pw.sh")
                print("File deleted")
            }
            catch {
                print("Error while deleting file \(error as NSError)")
            }
            print("Password file deleted")
            isTorLaunched = false
        }
        
        task.launch()
        isTorLaunched = true
        task.waitUntilExit()
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
    launchTor(hashedPassword: hash)
}