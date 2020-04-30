//
//  NSDecimalNumber+Ext.swift
//  chat
//
//  Created by Grand on 2020/4/26.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

extension NSDecimalNumber {
    
    func formatterToString(decimals: Int = 12) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimals
        formatter.roundingMode = .floor
        return formatter.string(from: self) ?? "0"
    }
}
