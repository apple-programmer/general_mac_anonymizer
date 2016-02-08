//
//  Really bad file.swift
//  MKO project
//
//  Created by Roman Nikitin on 07.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Foundation
import Cocoa
import CoreData

func initPaths() {
    let delegate = NSApplication.sharedApplication().delegate as! AppDelegate
    let context = delegate.managedObjectContext
    
    let fetch = NSFetchRequest(entityName: "Privoxy")
    
    do {
        let result = try context.executeFetchRequest(fetch)
        let contents = result as! [NSManagedObject]
        for obj in contents {
            print(obj.valueForKey("configContent"))
        }
    }
    catch {
        print("Error while reading core data \(error)")
    }
}
