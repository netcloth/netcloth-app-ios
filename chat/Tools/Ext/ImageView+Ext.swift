//
//  ImageView+Ext.swift
//  chat
//
//  Created by Grand on 2020/2/12.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation
import SDWebImage

extension UIImageView {
    
    //imageView.sd_setImage(with: URL(string: "http://www.domain.com/path/to/image.jpg"), placeholderImage: UIImage(named: "placeholder.png"))
    
    enum UseType {
        case assist
    }
    
    func nc_typeImage(url: String, type: UseType = .assist) {
        nc_imageSet(url: url, placeImage: nil)
    }
    
    func nc_imageSet(url: String,placeImage: UIImage? = nil) {
        let rurl = URL(string: url)
        self.sd_setImage(with: rurl, placeholderImage: placeImage)
    }
    
}
