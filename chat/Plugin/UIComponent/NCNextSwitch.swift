//
//  NCNextSwitch.swift
//  chat
//
//  Created by Grand on 2020/4/23.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class NCNextSwitch: UISwitch {
    
    var color_ontint = UIColor(hexString: "#E8EBFF") //浅蓝色
    var color_thumbOnTint = UIColor(hexString: Color.blue)
    
    var color_tint = UIColor(hexString: "#EFEFF1") //浅灰色
    var color_thumbTint = UIColor(hexString: Color.gray)
    
    var disbag = DisposeBag()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tintColor = color_tint
        self.onTintColor = color_ontint
        
        configEvent()
    }
    
    func configEvent() {
        self.rx.isOn.subscribe(onNext: { [weak self] (isON) in
            isON ? self?.configON() : self?.configOff()
        }).disposed(by: disbag)
    }
    
    fileprivate func configON() {
        self.thumbTintColor = color_thumbOnTint
    }
    
    fileprivate func configOff() {
        self.thumbTintColor = color_thumbTint
    }
}
