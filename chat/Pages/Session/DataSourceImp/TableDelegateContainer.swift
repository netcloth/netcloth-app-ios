//
//  TableDelegateManager.swift
//  chat
//
//  Created by Grand on 2020/3/19.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class TableDelegateContainer: NSObject {
    var delegates:NSPointerArray = NSPointerArray.weakObjects()  //UnsafeMutableRawPointer
    func add(delegate: AnyObject) {
        if let t = delegate as? UnsafeMutableRawPointer {
            delegates.addPointer(t)
        }
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        for item in delegates.allObjects {
            if (item as AnyObject).responds(to: aSelector) {
                return true
            }
        }
        return false
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        for item in delegates.allObjects {
            if (item as AnyObject).responds(to: aSelector) {
                return item
            }
        }
        return nil
    }
}


/// unretained
func bridge<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func bridge<T : AnyObject>(ptr : UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

/// retained
func bridgeRetained<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
}

func bridgeTransfer<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}
