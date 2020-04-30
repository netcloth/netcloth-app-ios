//
//  GuideView.swift
//  chat
//
//  Created by Grand on 2020/3/30.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class GuideView: UIControl {
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        
    }
    
    /// add to key window, mask
    func addMask(maskRect: CGRect,
                 cornerRadius: CGFloat,
                 image: UIImage?,
                 imageRect: CGRect?
    ) {
        let onView = Router.rootWindow
        let frame = onView?.bounds ?? CGRect.zero
        self.frame = frame
        onView?.addSubview(self)
        
        
        //绘制镂空的区域
        let maskPath = UIBezierPath(rect: frame)
        let holePath = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius)
        maskPath.append(holePath)
        
        let mask = CAShapeLayer()
        mask.backgroundColor = UIColor(rgb: 0x041036).cgColor
        mask.opacity = 0.8
        mask.fillRule = CAShapeLayerFillRule.evenOdd
        mask.path = maskPath.cgPath
        
        self.layer.insertSublayer(mask, at: 0)
        
        if let img = image {
            let iv = UIImageView(image: img)
            self.addSubview(iv)
            iv.frame = CGRect(x: 0, y: 100, width: iv.width, height: iv.height)
            if let rect = imageRect {
                iv.frame = rect
            }
        }
    }

}
