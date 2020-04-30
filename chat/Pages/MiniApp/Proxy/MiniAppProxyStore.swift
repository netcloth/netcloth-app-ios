//
//  MiniAppProxyStore.swift
//  chat
//
//  Created by Grand on 2020/3/26.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class MiniAppProxyStore: NSObject {
    @objc dynamic var openProxy: Bool = false
    
    @objc dynamic var host: String = ""
    @objc dynamic var port: Int = 0
    
}
