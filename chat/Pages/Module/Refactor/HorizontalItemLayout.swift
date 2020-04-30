







import Foundation



public final class HorizontalItemLayout: UICollectionViewFlowLayout {
    
    private lazy var allAttrs = [UICollectionViewLayoutAttributes]()
    
    public var viewSize: CGSize? 
    
    var rows = 3
    var columns = 6
    

    
    override public var collectionViewContentSize: CGSize {
        
        guard let vs = viewSize else {
            return CGSize.zero
        }
        let pages = CGFloat(ceil(Double(allAttrs.count) / Double(rows * columns)))
        return CGSize(width: vs.width * pages,
                      height: vs.height)
    }


    
    override init() {
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = .horizontal
    }

    
    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView, let vs = viewSize else { return }
        
        var item_size = self.itemSize
        var section_inset = self.sectionInset
        var columnSpace = self.minimumLineSpacing 
        var rowSpace = self.minimumInteritemSpacing 
        
        var x_i:CGFloat = 0, y_i: CGFloat = 0, page_i: Int = 0
        var onePageCount = rows * columns
        
        (0 ..< collectionView.numberOfItems(inSection: 0)).forEach { (i) in
            page_i = i / onePageCount
            let bigx = (CGFloat(page_i) * vs.width + section_inset.left)
            let sx = CGFloat(i % columns) * (item_size.width + columnSpace)
            x_i = bigx + sx
            
            var column_i = (i / columns) % rows
            let bigY = section_inset.top
            let sy = CGFloat(column_i) * (item_size.height + rowSpace)
            y_i = bigY + sy
            
            let attrs = layoutAttributesForItem(at: IndexPath(item: i, section: 0))!
            attrs.frame = CGRect(x: x_i, y: y_i, width: item_size.width, height: item_size.height)
            allAttrs.append(attrs)
        }
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return allAttrs.filter { rect.contains($0.frame) }
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        allAttrs.removeAll()
    }
}
