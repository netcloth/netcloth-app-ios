  
  
  
  
  
  
  

import Foundation

@objc protocol EmojKeyBoardViewDelegate: NSObjectProtocol {
      
    func onInputEmoj(str: String)
    
      
    func onDeleteInput()
    
      
    func onSendKeyTap()
}

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
        
        
        self.collectionView.adjustOffset()        
        if let fl =  self.collectionView.collectionViewLayout as? HorizontalItemLayout {
            
            let cw = itemSize.width * CGFloat(fl.columns)
            let ch = itemSize.height * CGFloat(fl.rows)
            let columnSpace = (vLen - inset.left - inset.right - cw) / CGFloat(fl.columns - 1)
            let rowSpace = (CGFloat(vHeight) - inset.top - inset.bottom - ch) / CGFloat(fl.rows - 1)
            
            
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
