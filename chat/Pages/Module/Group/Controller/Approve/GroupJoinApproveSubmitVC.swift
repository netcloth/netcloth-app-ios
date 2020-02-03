  
  
  
  
  
  
  

import UIKit

class GroupJoinApproveSubmitVC: UIViewController {

    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var doneBtn: UIButton?
    
    var groupPrikey: Data?
    var pubkey :String?
    var name: String?
    var notice: String?
    
    var nickname: String?
    var source: Int?
    var inviter: String?
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
              
        }
        super.viewDidLoad()
    }
    
      
    @IBAction func onTapDone() {
        let summit = textView?.text ?? ""
        sendRealJoin(summit)
    }
    
    func sendRealJoin(_ desc: String) {
        self.showLoading()
        CPGroupChatHelper.sendGroupJoin(nickname,
                                        desc: desc,
                                        source: Int32(source!),
                                        inviterPubkey: inviter,
                                        groupPubkey: pubkey) { [weak self] (res) in
            self?.dismissLoading()
            let json = JSON(res)
            let code = json["code"].int
            if (code == ChatErrorCode.OK.rawValue || code == ChatErrorCode.memberDuplicate.rawValue) {
                Toast.show(msg: "Group_Approve_request_Ok".localized() , onWindow: true)
                Router.dismissVC(animate: true, completion: nil, toRoot: true)
            }
            else if (code == ChatErrorCode.partialOK.rawValue) {
                  
            }
            else if (code == ChatErrorCode.memberExceed.rawValue) {
                  
                self?.showFailJoinAlert()
            }
            else {
                  
                Toast.show(msg: "System error".localized())
            }
        }
    }
    
    
    func showFailJoinAlert() {
        guard let failV = R.loadNib(name: "UploadResultAlert") as? UploadResultAlert  else {
            Toast.show(msg: "System error".localized())
            return
        }
        failV.imageView?.image = UIImage(named: "backup_result_fail")
        failV.msgLabel?.text = "Group_Join_ecc_tip".localized()
        failV.okButton?.setTitle("OK".localized(), for: .normal)
        Router.showAlert(view: failV)
        failV.okBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

}
