







import Foundation

public protocol TextInput {
    func limitLength(by rule: String?, maxLength:Int?)
    var textSelectedRange: NSRange? {get set}
}

extension TextInput where Self : UITextInput {
    public var textSelectedRange: NSRange? {
        get {
            if let st = self.selectedTextRange {
                let location = self.offset(from: self.beginningOfDocument, to: st.start)
                let length = self.offset(from: st.start, to: st.end)
                return NSMakeRange(location, length)
            }
            return nil
        }
        set {
            if let n = newValue {
                guard let  startPosition = self.position(from: self.beginningOfDocument, offset: n.location) else {
                    return
                }
                guard let endPosition = self.position(from: self.beginningOfDocument, offset:n.location + n.length) else {
                    return
                }
                let stcc = self.textRange(from: startPosition, to: endPosition)
                self.selectedTextRange = stcc
            }
        }
    }
}

extension String {
    
    public func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension NSString {
    public func appley(rule: String?, maxLength: Int?) -> String? {
        var subStr: NSString = self
        if let r = rule {
            let range = self.range(of: r, options: .regularExpression)
            if range.location != NSNotFound {
                subStr = self.substring(with: range) as NSString
            } else {
                subStr = ""
            }
        }
        
        if let ml = maxLength, ml > 0, subStr.length > ml {
            subStr = subStr.substring(to: ml) as NSString
        }
        return subStr as String
    }
}

public extension Array {
    public subscript(safe index: Int) -> Element? {
        if self.count > index, index >= 0 {
            return self[index]
        }
        else {
            return nil
        }
    }
}


extension UITextField : TextInput {
    
    public func limitLength(by rule: String?, maxLength: Int?) {
        
        if let marked = self.markedTextRange {
            if let text_marked =  self.text(in: marked) {
                if let oriText: NSString = self.text as? NSString {
                    var no_marked = oriText.replacingOccurrences(of: text_marked, with: "")

                    if let subStr = no_marked.appley(rule: rule, maxLength: maxLength) {
                        if subStr == no_marked {
                            
                            return
                        }
                       self.text = subStr
                       try?  self.setMarkedText(text_marked, selectedRange: NSMakeRange(subStr.count, text_marked.count))
                    }

                }
            }
        }
        else {
            if let text = self.text as NSString? {
                if let subStr: NSString = text.appley(rule: rule, maxLength: maxLength) as? NSString {
                    if (subStr.isEqual(to: text as String) == false) {
                        self.text = subStr as String
                    }
                }
            }
        }
    }
}

extension UITextView : TextInput {
    
    public func limitLength(by rule: String?, maxLength: Int?) {
        
        if let marked = self.markedTextRange {
            if let text_marked =  self.text(in: marked) {
                if let oriText: NSString = self.text as? NSString {
                    var no_marked = oriText.replacingOccurrences(of: text_marked, with: "")

                    if let subStr = no_marked.appley(rule: rule, maxLength: maxLength) {
                        if subStr == no_marked {
                            
                            return
                        }
                       self.text = subStr
                       try?  self.setMarkedText(text_marked, selectedRange: NSMakeRange(subStr.count, text_marked.count))
                    }

                }
            }
        }
        else {
            if let text = self.text as NSString? {
                if let subStr: NSString = text.appley(rule: rule, maxLength: maxLength) as? NSString {
                    if (subStr.isEqual(to: text as String) == false) {
                        self.text = subStr as String
                    }
                }
            }
        }
    }
}


open class PlaceHolderTextView: UITextView {
    @IBOutlet public var placeHolder: UILabel?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector:#selector(textChange) , name: UITextView.textDidChangeNotification, object: nil)
    }
    
    open override var text: String! {
        set {
            super.text = newValue
            textChange()
        }
        get {
            return super.text
        }
    }
    
    @objc func textChange() {
        self.placeHolder?.isHidden = !self.text.isEmpty
    }
}


open class AutoHeightTextView: PlaceHolderTextView {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config() {
        self.isScrollEnabled = false
        self.textContainerInset = UIEdgeInsets.zero
        self.textContainer.lineFragmentPadding = 0
    }
    
}
