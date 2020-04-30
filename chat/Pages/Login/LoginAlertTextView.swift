//
//  LoginAlertTextView.swift
//  chat
//
//  Created by Grand on 2020/4/15.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation


class LoginAlertTextView: AutoHeightTextView {
    
    var textViewDelegate = MsgChatTextViewHandle()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isEditable = false
        self.isSelectable = true
        self.bounces = false
        self.bouncesZoom = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.delegate = textViewDelegate
        self.isExclusiveTouch = true
        self.dataDetectorTypes = [.link]
    }
    
    override var text: String! {
        didSet {
            let attributedString = NSMutableAttributedString(string: text)

            let textRange = NSMakeRange(0, (text as NSString).length)

            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor!, range: textRange)
            attributedString.addAttribute(NSAttributedString.Key.font, value: font!, range: textRange)
            
            var find1 = "Use_Service_Protocol".localized()
            var range = (self.text as NSString).range(of: find1)
            if range.location != NSNotFound {
                let linkV = Config.NetOfficial.ServiceUrl
                let textAttributes: [NSAttributedString.Key : Any]! =
                    [NSAttributedString.Key.foregroundColor: UIColor(hexString: Color.blue),
                     NSAttributedString.Key.link: linkV]

                attributedString.addAttributes(textAttributes, range: range)
            }
            
            
            find1 = "Use_Private_Protocol".localized()
            range = (self.text as NSString).range(of: find1)
            if range.location != NSNotFound {
                let linkV = Config.NetOfficial.PrivacyUrl
                let textAttributes: [NSAttributedString.Key : Any]! =
                    [NSAttributedString.Key.foregroundColor: UIColor(hexString: Color.blue),
                     NSAttributedString.Key.link: linkV]

                attributedString.addAttributes(textAttributes, range: range)
            }
            
            self.attributedText = attributedString
        }
    }
}
