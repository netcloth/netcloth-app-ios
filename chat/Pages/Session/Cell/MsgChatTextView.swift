







import UIKit
import swift_cli

enum DetectedDataType: String, CaseIterable {
    case URL = "(((?i)https?|ftp|file):
}


class MsgChatTextView: AutoHeightTextView {
    
    var linkColor: UIColor!
    
    var textViewDelegate = MsgChatTextViewHandle()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isEditable = false
        self.isSelectable = true
        self.bounces = false
        self.bouncesZoom = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.delegate = textViewDelegate
        self.isExclusiveTouch = true
        self.dataDetectorTypes = [.link]
    }
    
    override var text: String! {
        didSet {
            let attributedString = NSMutableAttributedString(string: text)

            let textRange = NSMakeRange(0, (text as NSString).length)

            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor!, range: textRange)
            attributedString.addAttribute(NSAttributedString.Key.font, value: font!, range: textRange)

            DetectedDataType.allCases.forEach { detectionType in
                let pattern = detectionType.rawValue
                let expression = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())

                expression.enumerateMatches(in: text, options: NSRegularExpression.MatchingOptions(), range: textRange) {  result, flags, stop in
                    if let result = result {
                        let textValue = (self.text as NSString).substring(with: result.range)

                        let textAttributes: [NSAttributedString.Key : Any]! =

                            [NSAttributedString.Key.foregroundColor: linkColor,
                             NSAttributedString.Key.link: textValue,
                             NSAttributedString.Key.underlineStyle : NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue),
                             NSAttributedString.Key(rawValue: detectionType.rawValue): detectionType.rawValue]

                        attributedString.addAttributes(textAttributes, range: result.range)
                    }
                }
            }
            self.attributedText = attributedString
        }
    }
}
