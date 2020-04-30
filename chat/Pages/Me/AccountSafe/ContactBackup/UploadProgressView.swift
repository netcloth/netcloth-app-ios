//
//  UploadProgressView.swift
//  chat
//
//  Created by Grand on 2019/10/29.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class UploadProgressView: AlertView, NCAlertInterface {
    private var progressV: LXWaveProgressView?
    @IBOutlet var containV: UIView?
    
    override func layoutSubviews() {
        if progressV == nil {
            progressV = LXWaveProgressView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            containV?.addSubview(progressV!)
        }
    }
    
    var progress: Double = 0 {
        didSet {
            progressV?.progress = CGFloat(self.progress)
        }
    }
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 181)
    }
}
