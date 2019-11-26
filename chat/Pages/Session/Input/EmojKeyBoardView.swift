







import Foundation

@objc protocol EmojKeyBoardViewDelegate: NSObjectProtocol {

    func onInputEmoj(str: String)
    

    func onDeleteInput()
    

    func onSendKeyTap()
}

fileprivate let rows = 3
fileprivate let columns = 6

class EmojKeyBoardView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var rightContainer: UIView!
    
    @objc weak var delegate: EmojKeyBoardViewDelegate? = nil
    
    let disbag = DisposeBag()
    
    lazy var emojArray:[String] = {
        let text = """
        😂 😱 😭 😘 😳 🙁
        🤗 😏 😍 😎 ☺️ 😜
        😋 😬 😤 😓 😰 😡
        🤪 🙄 😷 😴 🧐 🤔
        🤭 🤫 🤐 😇 ❤️ 💔
        🙏 👍 🤝 👏 💪 👌
        👻 🤡 💀 💩 🙈 🐶
        🍄 ☀️ 🎂 🍺 🎊 🎉
        🚗 🎁 🏃‍♂️ 🏃‍♀️
        """
        let cs:CharacterSet = NSCharacterSet(charactersIn: " \r\n") as CharacterSet
        return text.components(separatedBy: cs)
    }()
    

    deinit {
        print("dealloc \(type(of: self))")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
        configEvent()
    }
    
    func configUI() {
        let vLen = YYScreenSize().width - self.rightContainer.width
        let vHeight = 180
        
        let inset = UIEdgeInsets(top: 10, left: 15, bottom: 30, right: 15)
        let itemSize = CGSize(width: 28, height: 37)
        
        let cw = itemSize.width * CGFloat(columns)
        let ch = itemSize.height * CGFloat(rows)
        let columnSpace = (vLen - inset.left - inset.right - cw) / CGFloat(columns - 1)
        let rowSpace = (CGFloat(vHeight) - inset.top - inset.bottom - ch) / CGFloat(rows - 1)
        
        
        self.collectionView.adjustOffset()        
        if let fl =  self.collectionView.collectionViewLayout as? HorizontalItemLayout {
            fl.sectionInset = inset
            fl.itemSize = itemSize
            fl.minimumLineSpacing  = columnSpace
            fl.minimumInteritemSpacing = rowSpace
            fl.scrollDirection = UICollectionView.ScrollDirection.horizontal
            fl.viewSize = CGSize(width: vLen, height: CGFloat(vHeight))
        }
        
        let cell = UINib(nibName: "EmojCollectionCell", bundle: nil)
        collectionView.register(cell, forCellWithReuseIdentifier: "EmojCollectionCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    func configEvent() {
        deleteButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.delegate?.onDeleteInput()
        }).disposed(by: disbag)
        
        sendButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.delegate?.onSendKeyTap()
        }).disposed(by: disbag)
    }
    
    
    override var intrinsicContentSize: CGSize {
        var h = 180
        if #available(iOS 11.0, *) {
            h += Int(Router.currentViewOfVC?.safeAreaInsets.bottom ?? 0)
        } else {

        }
        return CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(h))
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.width)
        self.pageControl.currentPage = page
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.emojArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojCollectionCell", for: indexPath)
        cell.reloadData(data: self.emojArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoj = self.emojArray[indexPath.item]
        self.delegate?.onInputEmoj(str: emoj)
    }
}



public final class HorizontalItemLayout: UICollectionViewFlowLayout {

    private lazy var allAttrs = [UICollectionViewLayoutAttributes]()
    
    public var viewSize: CGSize?


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
}


