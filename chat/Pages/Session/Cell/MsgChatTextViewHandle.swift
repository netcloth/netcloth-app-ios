







import UIKit

class MsgChatTextViewHandle: NSObject, UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith handleUrl: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let urlstr = handleUrl.absoluteString.lowercased()
        if urlstr.hasPrefix("http")  == false {
            let suburl = "http:
            if let url = URL(string: suburl) {
                UIApplication.shared.open(url)
            }
            return false
        }
        return true
    }
    
}
