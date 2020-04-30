







import Foundation

extension UIViewController {
    func checkCanReload() -> Bool {
        var topVC = self.navigationController as? UIViewController
        if let topNav =  topVC as? UINavigationController {
            topVC = topNav.topViewController
        }
        if let tabVC = topVC as? UITabBarController {
            topVC = tabVC.selectedViewController
        }
        if topVC == self {
            return true
        }
        return false
    }
}


extension UIViewController {
    
    
    open func setTitleImage(_ title: String,
                            image: UIImage,
                            color: UIColor = UIColor.white,
                            font: UIFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)) -> UIView
    {
        
        let cv = UIView()
        var stackV = UIStackView()
        cv.addSubview(stackV)
        
        stackV.axis = .horizontal
        stackV.distribution = .fill
        stackV.alignment = .center
        stackV.spacing = 10
        
        let label = UILabel()
        label.text = title
        label.font = font
        label.textColor = color
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        stackV.addArrangedSubview(label)
        
        let imageV = UIImageView(image: image)
        imageV.setContentHuggingPriority(.required, for: .horizontal)
        imageV.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        stackV.addArrangedSubview(imageV)
        
        stackV.snp.makeConstraints { (maker) in
            maker.center.equalTo(cv)
            maker.height.equalTo(30)
            maker.leading.greaterThanOrEqualToSuperview()
            maker.trailing.lessThanOrEqualToSuperview()
        }
        
        self.navigationItem.titleView = cv
        return cv
    }
    
}

