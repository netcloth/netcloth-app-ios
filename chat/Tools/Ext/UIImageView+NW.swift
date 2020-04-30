//
//  UIImageView+NW.swift
//  chat
//
//  Created by Grand on 2020/1/17.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

extension UIImageView {
    
    func nw_setImage(urlString: String, placeImg: UIImage? = nil) {
        self.image = placeImg
        NW.getDataUrl(path: urlString, para: nil) { (r, data) in
            if r == true, let d = data as? Data {
                self.image = UIImage(data: d)
            }
        }
    }
    
}
