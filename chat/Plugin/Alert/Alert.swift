//
//  Alert.swift
//  chat
//
//  Created by Grand on 2019/8/26.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

class NCAlertViewController: BaseViewController {
    
    private var content: (UIView & NCAlertInterface)?
    private var didAppear:Bool = false
    
    private var preDiff: CGFloat?
    
    deinit {
        IQKeyboardManager.shared.keyboardDistanceFromTextField = preDiff ?? 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        
        preDiff = IQKeyboardManager.shared.keyboardDistanceFromTextField
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 70;
        
        if let bg = self.content?.ncBgColor?() {
            self.view.backgroundColor = bg
        } else {
            let color = UIColor(hexString: Color.black)?.withAlphaComponent(0.6)
            self.view.backgroundColor = color// UIColor(rgb: 0, alpha: 0.6)
        }
        
        if let ct = content {
            self.view.addSubview(ct)
            ct.snp.makeConstraints { (maker) in

                //point
                if let point = ct.ncCenter?() {
                    maker.center.equalTo(point)
                }
                else if let bottom = ct.ncMaxY?() {
                    maker.centerX.equalTo(self.view)
                    
                    //bottom, Note: conflict with center
                    if #available(iOS 11.0, *) {
                        maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-bottom)
                    } else {
                        maker.bottom.equalTo(self.view).offset(-bottom)
                    }
                }
                else {
                    maker.center.equalTo(self.view)
                }
                
                //size
                if let size = ct.ncSize?() {
                    maker.width.equalTo(size.width)
                    if let _ = ct as? UIImageView {
                        maker.height.equalTo(size.height)
                    } else {
                        maker.height.greaterThanOrEqualTo(size.height)
                    }
                }
                else {
                    maker.width.equalTo(300)
                    maker.height.greaterThanOrEqualTo(173)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let ct = content , didAppear == false {
            self.view.layoutIfNeeded()
            if let show = ct.ncShowAnimate?() {
                if show == true {
                    ct.showAlertAnimate()
                }
            } else {
                ct.showAlertAnimate()
            }
        }
        didAppear = true
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
        
        if self.content?.ncAutoDismiss?() == true {
            Router.dismissVC()
        }
    }

    func addContent(view: UIView & NCAlertInterface ) {
        content = view
    }
}


@objc protocol NCAlertInterface {
    //size
    @objc optional func ncCenter() -> CGPoint
    @objc optional func ncSize() -> CGSize
    @objc optional func ncMaxY() -> CGFloat
    
    //func
    @objc optional func ncAutoDismiss() -> Bool
    @objc optional func ncBgColor() -> UIColor
    @objc optional func ncShowAnimate() -> Bool //default true
}

extension UIView {
    var alertViewController: NCAlertViewController? {
        get {
            return self.viewController as? NCAlertViewController
        }
    }
    
    func showAlertAnimate() {
        
        let popAnimation = CAKeyframeAnimation(keyPath: "transform")
        popAnimation.duration = 0.4;
        
        popAnimation.values = [
        NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),
        NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),
        NSValue(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),
        NSValue(caTransform3D: CATransform3DIdentity)
        ]
        
        popAnimation.keyTimes = [0.0, 0.5, 0.75, 1.0]
        
        popAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        
        self.layer.add(popAnimation, forKey: nil)
    }
    
    func showPopTopAnimate() {
        self.layoutIfNeeded()
        self.transform = self.transform.translatedBy(x: 0, y: self.height)
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.transform = CGAffineTransform.identity
        }
    }
}

extension Router {
    
     static func showAlert(view: UIView & NCAlertInterface) {
        let vc = NCAlertViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        vc.addContent(view: view)
        Router.present(vc: vc)
    }
    
    static func dismissAlert(view: UIView & NCAlertInterface) {
        if view.viewController == nil {
            return
        }
        Router.dismissVC()
    }
    
}
