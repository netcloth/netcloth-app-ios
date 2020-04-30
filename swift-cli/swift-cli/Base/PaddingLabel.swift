







import Foundation

open class PaddingLabel: UILabel {
    
    
    @IBInspectable public var lineSpace:CGFloat = 0 {
        didSet {
            let text = self.text ?? ""
            self.text = nil
            let style = NSMutableParagraphStyle()
            style.lineSpacing = self.lineSpace
            style.lineBreakMode = self.lineBreakMode

            let attrString:NSMutableAttributedString = NSMutableAttributedString(string: text)
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: text.count))

            self.attributedText = attrString;


        }
    }
    
    
    public var edgeInsets: UIEdgeInsets? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    open override func draw(_ rect: CGRect) {
        super.drawText(in:rect.inset(by: edgeInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
    }
    
    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width = size.width + ((self.edgeInsets?.left ?? 0) + (self.edgeInsets?.right ?? 0))
        size.height = size.height +  ((self.edgeInsets?.top ?? 0)
            + (self.edgeInsets?.bottom ?? 0))
        return size;
    }
    
}
