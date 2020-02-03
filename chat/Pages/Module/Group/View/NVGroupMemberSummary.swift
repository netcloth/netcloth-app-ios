  
  
  
  
  
  
  

import UIKit

class NVGroupMemberSummary: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var bottomV: UIStackView?
    @IBOutlet weak var moreBtn: UIButton?
    
    let disbag = DisposeBag()
    var didRefreshContent: (() -> Void)? 
    
    let inset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let itemSize = CGSize(width: 50, height: 70)
    
    var dataArray: [CPGroupMember]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    
      
    func viewHeight() -> CGFloat {
        return collectionViewHeight() + 40
    }
    
    func collectionViewHeight() -> CGFloat {
        return inset.top + inset.bottom +
            itemSize.height * CGFloat(nowNumberRows()) +
            CGFloat((nowNumberRows() - 1) * 17)
    }
    
    func nowNumberRows() -> Int {
        let rows = Double(self.dataArray?.count ?? 1) / 5.0
        return  Int(ceil(Double(rows)))
    }
    
    
    
      
    func configUI() {
        self.collectionView?.isPrefetchingEnabled = false
        let vLen = YYScreenSize().width
        if let fl =  self.collectionView?.collectionViewLayout as? HorizontalItemLayout {
            fl.rows = 2
            fl.columns = 5
            
            let cw = itemSize.width * CGFloat(fl.columns)
            let ch = itemSize.height * CGFloat(fl.rows)
            let columnSpace = (vLen - inset.left - inset.right - cw) / CGFloat(fl.columns - 1)
            let rowSpace:CGFloat = 17
            
            fl.sectionInset = inset
            fl.itemSize = itemSize
            fl.minimumLineSpacing  = columnSpace
            fl.minimumInteritemSpacing = rowSpace
            fl.scrollDirection = UICollectionView.ScrollDirection.horizontal
        }
        
        collectionView?.adjustOffset()
        let cell = UINib(nibName: "GroupMemberSumCell", bundle: nil)
        collectionView?.register(cell, forCellWithReuseIdentifier: "GroupMemberSumCell")
    }
    
    func configEvent() {
        
          
        self.moreBtn?.rx.tap.subscribe(onNext: {
            if let vc = R.loadSB(name: "GroupMemberList", iden: "GroupMemberListVC") as? GroupMemberListVC {
                Router.pushViewController(vc: vc)
            }
        }).disposed(by: disbag)
        
          
        self.roomService?.groupSummaryMember
            .map({ [weak self] (source) -> [CPGroupMember] in
            var array: [CPGroupMember] = []
            array.append(contentsOf: source)
            
            let add =  CPGroupMember()
            add.fakePlaceType = 1
            array.append(add)
            
            let isMaster = self?.roomService?.isMeGroupMaster.value
            if isMaster == true {
                let reduce =  CPGroupMember()
                reduce.fakePlaceType = 2
                array.append(reduce)
            }
              
            self?.dataArray = array
            if let fl =  self?.collectionView?.collectionViewLayout as? HorizontalItemLayout {
                let vLen = YYScreenSize().width
                let vHeight = self?.viewHeight() ?? 0
                fl.viewSize = CGSize(width: vLen, height: vHeight)
                fl.invalidateLayout()
            }
            self?.didRefreshContent?()
            return array
        }).asDriver(onErrorJustReturn: [])
            .drive(collectionView!.rx.items(cellIdentifier: "GroupMemberSumCell", cellType: GroupMemberSumCell.self)) {
                [weak self] (row, model, cell) in
                cell.reloadData(data: model)
        }.disposed(by: disbag)
        
        self.collectionView?.rx.modelSelected(CPGroupMember.self).subscribe(onNext: { [weak self](member) in
            let type = member.fakePlaceType
            
            if type == 0 {
                if let vc = R.loadSB(name: "GroupMemberCard", iden: "GroupMemberCardVC") as? GroupMemberCardVC {
                    vc.contactPublicKey = member.hexPubkey
                    Router.pushViewController(vc: vc)
                }
            }
            else if type == 1 {
                let isMaster = self?.roomService?.isMeGroupMaster.value
                let inviteType = self?.roomService?.chatContact?.value.inviteType
                if isMaster == false,
                    inviteType == CPGroupInviteType.onlyOwner.rawValue {
                    InnerHelper.showOnlyGroupAdminInviteTip()
                    return
                }
                
                  
                if let vc = R.loadSB(name: "GroupInviteFriendsVC", iden: "GroupInviteFriendsVC") as? GroupInviteFriendsVC {
                    Router.pushViewController(vc: vc)
                }
            }
            else if type == 2 {
                  
                if let vc = R.loadSB(name: "GroupInviteFriendsVC", iden: "GroupInviteFriendsVC") as? GroupInviteFriendsVC {
                    vc.pageTag = 1
                    Router.pushViewController(vc: vc)
                }
            }
        }).disposed(by: disbag)
    }

    
    override var intrinsicContentSize: CGSize {
        var h = self.viewHeight()
        return CGSize(width: UIView.noIntrinsicMetric, height: h)
    }
}
