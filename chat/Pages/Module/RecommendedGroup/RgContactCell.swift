







import UIKit

class RgContactCell: ContactCell {
    
    var disposeBag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func reloadData(data: Any) {
        if let d = data as? CPContact {
            if d.remark.isEmpty {
                requestGroupName(publicKey: d.publicKey).subscribe(onNext: { [weak self] (groupInfo) in
                    d.remark = groupInfo.name
                    self?._reloadData(data: d)
                }).disposed(by: disposeBag)
            } else {
                _reloadData(data: d)
            }
        }
    }
    
    fileprivate func _reloadData(data: CPContact) {
        super.reloadData(data: data)
    }
    
    
    fileprivate func requestGroupName(publicKey: String) -> Observable<CPGroupInfoResp> {
        return Observable.create { (observer) -> Disposable in
            CPGroupManagerHelper.requestServerGroupInfo(publicKey) { (r, msg, rsp) in
                if let groupInfo = rsp, r == true {
                    observer.onNext(groupInfo)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
