  
  
  
  
  
  
  

import UIKit

  
@objc class DistinctSenderCell: UITableViewCell {
    
    @IBOutlet weak var smallRemarkL: UILabel?
    @IBOutlet weak var remarkL: UILabel?
    
    @IBOutlet weak var msgL: UILabel?
    
    @IBOutlet weak var timeL: UILabel?
    @IBOutlet weak var unreadL: UILabel?
    
    var disbag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disbag = DisposeBag()
    }
    
    override func reloadData(data: Any) {
        if let notice = data as? CPGroupNotify {
            if notice.manualDecode == true {
                _reloadData(notice)
            } else {
                InnerHelper.decode(notice: notice)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [weak self] (r) in
                        if r {
                            self?._reloadData(notice)
                        }
                    }).disposed(by: disbag)
            }
            
            notice.rx.observe(DMNotifyStatus.self, "status")
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (e) in
                self?.reloadStatus(notice: notice)
            }).disposed(by: disbag)
        }
    }
    
    
    
    fileprivate func _reloadData(_ notice: CPGroupNotify) {
        let senderNickName = notice.decodeJoinRequest?.nickName ?? ""
        let desc = notice.decodeRequestReason()
        
        remarkL?.text = senderNickName
        smallRemarkL?.text = senderNickName.getSmallRemark()
        
          
        msgL?.text = desc
    
          
        timeL?.text = Time.timeDesc(from: notice.createTime ?? NSDate().timeIntervalSince1970, includeH_M: false)
        
          
        reloadStatus(notice: notice)
    }
    
    fileprivate func reloadStatus(notice: CPGroupNotify) {
          
        let r = getStatusDesc(status: notice.status)
        unreadL?.text = r.desc
        unreadL?.textColor = r.color
    }
    
    
    fileprivate func getStatusDesc(status: DMNotifyStatus) -> (desc: String?, color: UIColor?) {
        
        switch status {
        case .unread:
            return ("Notify_status_unread".localized(), UIColor(hexString: "#5ABB27"))
        case .read:
            return ("Notify_status_read".localized(), UIColor(hexString: "#F77221"))
        case .fulfilled:
            return ("Notify_status_fulfilled".localized(), UIColor(hexString: "#BFC2CC"))
        case .reject:
            return ("Notify_status_reject".localized(), UIColor(hexString: "#FF4141"))
        case .expired:
            return ("Notify_status_expired".localized(), UIColor(hexString: "#BFC2CC"))
            
        default:
            return (nil, nil)
        }
    }

}
