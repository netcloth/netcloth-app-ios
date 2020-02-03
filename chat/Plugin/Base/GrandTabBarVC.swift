  
  
  
  
  
  
  

import UIKit
import swift_cli

class GrandTabBarVC: UITabBarController {
    
    deinit {
        print("dealloc - " + self.className())
    }
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideBlackLine()
        configUI()
        configEvent()
        
          
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
            self?.configThirdPart()
        }
    }
    
    lazy var backupTip: BackupTipView? = {
        let v = R.loadNib(name: "BackupTipView") as? BackupTipView
        return v
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleTipShow()
    }
    
    func handleTipShow() {
          
        let c = BackupTipViewHelper.checkCanShow()
        self.backupTip?.showStatus(showAccount: c.showAccount, showContact: c.showContact)
        guard let b = self.backupTip else {
            return
        }
        self.view.addSubview(b)
        b.snp.remakeConstraints { (maker) in
            maker.left.right.equalTo(self.view)
            var tabbarH = self.tabBar.height - 2
            if #available(iOS 11.0, *) {
                let originTabH = self.tabBar.height
                let safeBottomH = self.view.safeAreaInsets.bottom
                let diff = originTabH - safeBottomH
                if diff >= 32 {
                    tabbarH = diff - 2
                }
                
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-tabbarH)
            } else {
                  
                maker.bottom.equalTo(self.view.snp.bottom).offset(-tabbarH)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        let ch: CGFloat = 54.0
        self.tabBar.height = ch
        if #available(iOS 11.0, *) {
            self.tabBar.top = self.view.height - ch - self.view.safeAreaInsets.bottom
        } else {
              
            self.tabBar.top = self.view.height - ch
        }
          
        for item in (self.tabBar.items ?? []) {
            item.setStyle(textColor: UIColor(hexString: "#BFC2CC"),
                          selectedColor: UIColor(hexString: "#3D7EFF"))
        }
    }
    
    override func viewDidLayoutSubviews() {
         handleTipShow()
    }
    
    func configUI() {
        self.view.backgroundColor = UIColor(hexString: Config.Color.app_bg_color)
        self.tabBar.setShadow(color: UIColor.lightGray, offset: CGSize(width: 0,height: -5), radius: 5, opacity: 0.1)
    }
    
    func configThirdPart() {
        try? Bugly.start(withAppId: Config.Bugly_APP_ID)
    }
    
      
    func switchToTab(index: Int) {
        self.selectedIndex = index
    }
}

extension GrandTabBarVC {
    func configEvent() {
        NotificationCenter.default.rx.notification( NoticeNameKey.newFriendsCountChange.noticeName).subscribe(onNext: { [weak self] (notice) in
            self?.reloadData()
        }).disposed(by: disbag)
    }
    
    func reloadData() {
        CPContactHelper.getAllContacts { [weak self]  (contacts) in
            let filter =  contacts.filter { (ct) -> Bool in
                if ct.status == .newFriend {
                    return true
                }
                return false
            }
            let contacts: [CPContact]? = filter
            let count = contacts?.count ?? 0
            if count > 0 {
                for item in (self?.tabBar.items ?? []) {
                    if item.tag == 1 {
                        item.badgeValue = "\(count)"
                        item.badgeColor = UIColor(hexString: "#FF4141")
                    }
                }
            }
        }
    }
}
