//
//  EmptyPlaceHolder.swift
//  chat
//
//  Created by Grand on 2019/8/12.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

let vTag = 201966

enum EmptyStatus {
    case Normal
    case Empty
    case Error
}

protocol Emptyable {
    func showEmpty(status: EmptyStatus) -> Void
    func emptyView() -> EmptyHolderView?
}

extension Emptyable where Self: UIView {
    
    func emptyView() -> EmptyHolderView? {
        if let v = getOnShowView()?.viewWithTag(vTag) as? EmptyHolderView {
            return v
        }
        return nil
    }
    
    func showEmpty(status: EmptyStatus) -> Void {
        var ev: EmptyHolderView?
        if let v = getOnShowView()?.viewWithTag(vTag) as? EmptyHolderView {
            ev = v
        } else {
            if let v = R.loadNib(name: "EmptyHolder") as? EmptyHolderView {
                v.tag = vTag
                ev = v
                getOnShowView()?.addSubview(v)
                v.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self)
                }
            }
        }
        ev?.showStatus(status)
    }
    
    private func getOnShowView() -> UIView? {
        if self.isKind(of: UIScrollView.self) {
            return self.viewController?.view
        } else {
            return self
        }
    }
}

extension UIView: Emptyable {}

class EmptyHolderView: UIView {
    @IBOutlet var tipsLabel: UILabel!
    @IBOutlet var tipsImgV: UIImageView!
    @IBOutlet var tapBtn: UIButton?
    
    func showStatus(_ status: EmptyStatus) {
        switch status {
        case .Normal:
            self.isHidden = true
        case .Empty:
            self.isHidden = false
        case .Error:
            self.isHidden = false
        default:
            self.isHidden = true
        }
    }
}
