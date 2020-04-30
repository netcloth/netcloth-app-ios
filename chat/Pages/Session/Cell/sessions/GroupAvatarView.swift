//
//  GroupAvatarView.swift
//  chat
//
//  Created by Grand on 2020/1/7.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class GroupAvatarView: UIView {
    @IBOutlet weak var peo1: People1?
    @IBOutlet weak var peo2: People2?
    @IBOutlet weak var peo3: People3?
    @IBOutlet weak var peo4: People4?
    
    func reloadData(members: [CPGroupMember]?) {
        
        let nicks = members?.map { (member) -> String in
            return member.nickName
        }
        reloadData(nickNames: nicks)
        
        
        if let first4s = members?.prefix(4) {
            let num = first4s.count
            switch num {
            case 1:
                let color = first4s[0].hexPubkey.randomColor()
                peo1?.p1?.backgroundColor = UIColor(hexString: color)
                
            case 2:
                let color = first4s[0].hexPubkey.randomColor()
                peo2?.p1?.backgroundColor = UIColor(hexString: color)
                let color1 = first4s[1].hexPubkey.randomColor()
                peo2?.p2?.backgroundColor = UIColor(hexString: color1)
                
            case 3:
                let color = first4s[0].hexPubkey.randomColor()
                peo3?.p1?.backgroundColor = UIColor(hexString: color)
                let color1 = first4s[1].hexPubkey.randomColor()
                peo3?.p2?.backgroundColor = UIColor(hexString: color1)
                let color2 = first4s[2].hexPubkey.randomColor()
                peo3?.p3?.backgroundColor = UIColor(hexString: color2)
                
            case 4:
                let color = first4s[0].hexPubkey.randomColor()
                peo4?.p1?.backgroundColor = UIColor(hexString: color)
                let color1 = first4s[1].hexPubkey.randomColor()
                peo4?.p2?.backgroundColor = UIColor(hexString: color1)
                let color2 = first4s[2].hexPubkey.randomColor()
                peo4?.p3?.backgroundColor = UIColor(hexString: color2)
                let color3 = first4s[3].hexPubkey.randomColor()
                peo4?.p4?.backgroundColor = UIColor(hexString: color3)
                
            default:
                print("end")
            }
        }
        
    }
    
    
    func reloadData(nickNames: [String]?) {
        let nickNames = nickNames?.prefix(4)
        hiddenAlls()
        if let nns = nickNames {
            let num = nns.count
            switch num {
            case 1:
                peo1?.isHidden = false
                peo1?.p1?.text = nns[0].getAvatarOneWord()
                
            case 2:
                peo2?.isHidden = false
                peo2?.p1?.text = nns[0].getAvatarOneWord()
                peo2?.p2?.text = nns[1].getAvatarOneWord()
                
            case 3:
                peo3?.isHidden = false
                peo3?.p1?.text = nns[0].getAvatarOneWord()
                peo3?.p2?.text = nns[1].getAvatarOneWord()
                peo3?.p3?.text = nns[2].getAvatarOneWord()
            case 4:
                peo4?.isHidden = false
                peo4?.p1?.text = nns[0].getAvatarOneWord()
                peo4?.p2?.text = nns[1].getAvatarOneWord()
                peo4?.p3?.text = nns[2].getAvatarOneWord()
                peo4?.p4?.text = nns[3].getAvatarOneWord()
                
            default:
                hiddenAlls()
            }
        }
    }
    
    func hiddenAlls() {
        peo1?.isHidden = true
        peo2?.isHidden = true
        peo3?.isHidden = true
        peo4?.isHidden = true
    }
}



class People1: UIView {
    @IBOutlet weak var p1: UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        p1?.text = nil
    }
}

class People2: UIView {
    @IBOutlet weak var p1: UILabel?
    @IBOutlet weak var p2: UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        p1?.text = nil
        p2?.text = nil
    }
}

class People3: UIView {
    @IBOutlet weak var p1: UILabel?
    @IBOutlet weak var p2: UILabel?
    @IBOutlet weak var p3: UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        p1?.text = nil
        p2?.text = nil
        p3?.text = nil
    }
}

class People4: UIView {
    @IBOutlet weak var p1: UILabel?
    @IBOutlet weak var p2: UILabel?
    @IBOutlet weak var p3: UILabel?
    @IBOutlet weak var p4: UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        p1?.text = nil
        p2?.text = nil
        p3?.text = nil
        p4?.text = nil
    }
}

