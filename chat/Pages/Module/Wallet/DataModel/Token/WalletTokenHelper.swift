//
//  WalletTokenHelper.swift
//  chat
//
//  Created by Grand on 2020/4/26.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation
import web3swift

class WalletTokenHelper {
    
    /// pnch -> nch
    static func parseAmount(amount: BigUInt,
                       numberDecimals: Int = 12,
                       formattingDecimals: Int = 12,
                       decimalSeparator: String = ".") -> String {
        
        return
        Web3Utils.formatToPrecision(amount,
                                    numberDecimals: numberDecimals,
                                    formattingDecimals: formattingDecimals,
                                    decimalSeparator:decimalSeparator ) ?? "0.00"
    }
    
    /// pnch -> nch
    static func parseAmount(amount: BigInt,
                       numberDecimals: Int = 12,
                       formattingDecimals: Int = 12,
                       decimalSeparator: String = ".") -> String {
        
        return
        Web3Utils.formatToPrecision(amount,
                                    numberDecimals: numberDecimals,
                                    formattingDecimals: formattingDecimals,
                                    decimalSeparator:decimalSeparator ) ?? "0.00"
    }
}

extension String {
    
    func bui_add(number: Int) -> String {
        guard let bu = BigUInt(self) else { return self }
        let result = bu + BigUInt(number)
        return result.description
    }
    
    ///eg nch -> pnch
    func bui_toBigUInt(decimals: Int = 12) -> BigUInt {
        let formatText = self.toDecimalNumber().formatterToString(decimals: decimals)
        return Web3Utils.parseToBigUInt(formatText, decimals: decimals) ?? 0
    }
    
    ///eg pnch -> nch
    func toDecimalBalance(bydecimals:Int) -> String {
        var b = BigUInt(self) ?? BigUInt(0)
        let nd = bydecimals
        let fd = nd
        let bstr = WalletTokenHelper.parseAmount(amount: b, numberDecimals: nd, formattingDecimals: fd)
        
        let b2b = bstr.toDecimalNumber().formatterToString()
        
        return b2b
    }
    
    func toDecimalNumber() -> NSDecimalNumber {
        return NSDecimalNumber(string: self)
    }
}

class TaskRun: NSObject {
    
    /// <#Description#>
    /// - Parameters:
    ///   - task: <#task description#>
    ///   - maxLoop: <#maxLoop description#>
    static func runTask(task: @escaping (@escaping ((Bool) -> Void)) -> Void,
                        overcount: @escaping () -> Void,
                        maxLoop:Int = 20,
                        timediff: TimeInterval = 3.0) -> Void {
        if maxLoop <= 0 {
            print("timecount overcount")
            overcount()
            return
        }
        let callback = { (resume:Bool) in
            if resume {
                let t = DispatchTime(floatLiteral: timediff)
                DispatchQueue.main.asyncAfter(deadline: t) {
                    TaskRun.runTask(task: task,
                                    overcount: overcount,
                                    maxLoop: (maxLoop - 1),
                                    timediff: timediff)
                }
            }
        }
        task(callback)
    }
}
