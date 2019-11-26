







import UIKit

protocol CommomChatCellInterface {
    func playAudio()
    func msgContentView() -> UIView?
}

@objc protocol ChatCommonCellDelegate {
    @objc optional
    func onTapAvatar(pubkey: String) -> Void
    @objc optional
    func onRetrySendMsg(_ msgId: CLongLong) -> Void
    
    @objc optional
    func onShowBigPhoto(_ img: UIImage, containerView: UIView) -> Void
}

@objc class ChatCommonCell: UITableViewCell, CommomChatCellInterface {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    weak var delegate: ChatCommonCellDelegate?
    
    func playAudio() {}
    
    func msgContentView() -> UIView? {
        return nil
    }
}
