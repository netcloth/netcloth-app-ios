//
//  MsgChatTextViewHandle.swift
//  chat
//
//  Created by Grand on 2020/3/30.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class MsgChatTextViewHandle: NSObject, UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith handleUrl: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let urlstr = handleUrl.absoluteString.lowercased()
        if urlstr.hasPrefix("http")  == false {
            let suburl = "http://" + urlstr
            if let url = URL(string: suburl) {
                UIApplication.shared.open(url)
            }
            return false
        }
        return true
    }
    
}
