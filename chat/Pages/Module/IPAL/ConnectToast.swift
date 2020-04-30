







import Foundation

class ConnectToast: AlertView, NCAlertInterface {
    
    @IBOutlet weak var step1L: UILabel?
    @IBOutlet weak var step1Img: UIImageView?
    @IBOutlet weak var step1Hub: UIActivityIndicatorView?
    
    @IBOutlet weak var step2L: UILabel?
    @IBOutlet weak var step2Img: UIImageView?
    @IBOutlet weak var step2Hub: UIActivityIndicatorView?
    
    @IBOutlet weak var step3L: UILabel?
    @IBOutlet weak var step3Img: UIImageView?
    @IBOutlet weak var step3Hub: UIActivityIndicatorView?
    
    @IBOutlet weak var bottomTipContainer: UIView?
    @IBOutlet weak var bottomTip: UILabel?
    
    @IBOutlet weak var allOkOrFailStack: UIStackView?
    @IBOutlet weak var allOkOrFailBtn: UIButton?    
    
    @IBOutlet weak var retryStack: UIStackView?
    @IBOutlet weak var retryBtn: UIButton?
    @IBOutlet weak var retrySeedNodeBtn: UIButton?
    
    enum Step: String {
        
        case C_1 = "in_step1_con"
        case C_2 = "in_step2_con"
        case C_3 = "in_step3_con"
        
        case C_1_1 = "step1_ok"
        case C_2_1 = "step2_ok"
        case C_3_1 = "step3_ok"
        
        case F_1_1 = "step1_fail"
        case F_2_1 = "step2_fail"
        case F_3_1 = "step3_fail"
    }
    
    
    var curStep: Step = .C_1 {
        didSet {
            switch self.curStep {
            case .C_1:
                deal1()
            case .C_1_1:
                suc1_1()
            case .F_1_1:
                fal1_1()
                
            case .C_2:
                deal2()
            case .C_2_1:
                suc2_1()
            case .F_2_1:
                fal2_1()
                
            case .C_3:
                deal3()
            case .C_3_1:
                suc3_1()
            case .F_3_1:
                fal3_1()
                
            default:
                deal1()
            }
        }
    }
    
    
    typealias ClickCallBack =  () -> Void
    var onBackTap: ClickCallBack?  
    var onEnterpriseTap: ClickCallBack?  
    
    var onRetryTap: ClickCallBack?  
    var onSwitchCIpalTap: ClickCallBack?  
    
    
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configEvent()
    }
    
    
    func configEvent() {
        self.allOkOrFailBtn?.addTarget(self, action: #selector(userTapAllOkOrFail), for: .touchUpInside)
        self.retryBtn?.addTarget(self, action: #selector(userTapRetry), for: .touchUpInside)
        self.retrySeedNodeBtn?.addTarget(self, action: #selector(userTapSwitchCipal), for: .touchUpInside)
    }
    
    @objc func userTapAllOkOrFail() {
        if curStep == .F_1_1 {
            onBackTap?()
        }
        else if curStep  == .C_3_1 {
            onEnterpriseTap?()
        }
    }
    
    @objc func userTapRetry() {
        onRetryTap?()
    }
    
    @objc func userTapSwitchCipal() {
        onSwitchCIpalTap?()
    }
    
    
    
    private func deal1() {
        titleLabel?.text = "ipal_connect_ing".localized()
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: true, hub: step1Hub)
        config(label: step2L, labcolor: Color.gray_bf, imgV: step2Img, ishid: true, hub: step2Hub)
        config(label: step3L, labcolor: Color.gray_bf, imgV: step3Img, ishid: true, hub: step3Hub)
        
        bottomTipContainer?.isHidden = true
        allOkOrFailStack?.isHidden = true
        retryStack?.isHidden = true
        
        configAnmateHub(animate1: true, animate2: false, animate3: false)
    }
    
    private func suc1_1() {
        titleLabel?.text = "ipal_connect_ing".localized()
        
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: false, imgName:"ipal_request_result_success",
               hub: step1Hub)
        
        config(label: step2L, labcolor: Color.gray_bf, imgV: step2Img, ishid: true, hub: step2Hub)
        config(label: step3L, labcolor: Color.gray_bf, imgV: step3Img, ishid: true, hub: step3Hub)
        
        bottomTipContainer?.isHidden = true
        allOkOrFailStack?.isHidden = true
        retryStack?.isHidden = true
        
        configAnmateHub(animate1: false, animate2: false, animate3: false)
    }
    
    private func fal1_1() {
        titleLabel?.text = "ipal_connect_fail".localized()
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: false, imgName:"ipal_request_result_fail",
               hub: step1Hub)
        config(label: step2L, labcolor: Color.gray_bf, imgV: step2Img, ishid: true, hub: step2Hub)
        config(label: step3L, labcolor: Color.gray_bf, imgV: step3Img, ishid: true, hub: step3Hub)
        
        bottomTipContainer?.isHidden = false
        allOkOrFailStack?.isHidden = false
        retryStack?.isHidden = true
        
        configAnmateHub(animate1: false, animate2: false, animate3: false)
        
        bottomTip?.text = "ipal_step1_fail_tip".localized()
        allOkOrFailBtn?.setTitle("Return".localized(), for: .normal)
        
    }
    
    
    private func deal2() {
        titleLabel?.text = "ipal_connect_ing".localized()
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: false, imgName:"ipal_request_result_success",  hub: step1Hub)
        config(label: step2L, labcolor: Color.black, imgV: step2Img, ishid: true, hub: step2Hub)
        config(label: step3L, labcolor: Color.gray_bf, imgV: step3Img, ishid: true, hub: step3Hub)
        
        bottomTipContainer?.isHidden = true
        allOkOrFailStack?.isHidden = true
        retryStack?.isHidden = true
        
        configAnmateHub(animate1: false, animate2: true, animate3: false)
    }
    
    private func suc2_1() {
        titleLabel?.text = "ipal_connect_ing".localized()
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: false, imgName:"ipal_request_result_success",  hub: step1Hub)
        config(label: step2L, labcolor: Color.black, imgV: step2Img, ishid: false,imgName:"ipal_request_result_success", hub: step2Hub)
        config(label: step3L, labcolor: Color.gray_bf, imgV: step3Img, ishid: true, hub: step3Hub)
        
        bottomTipContainer?.isHidden = true
        allOkOrFailStack?.isHidden = true
        retryStack?.isHidden = true
        
        configAnmateHub(animate1: false, animate2: false, animate3: false)
    }
    
    private func fal2_1() {
        titleLabel?.text = "ipal_connect_fail".localized()
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: false, imgName:"ipal_request_result_success",  hub: step1Hub)
        
        config(label: step2L, labcolor: Color.black, imgV: step2Img, ishid: false,imgName:"ipal_request_result_fail", hub: step2Hub)
        
        config(label: step3L, labcolor: Color.gray_bf, imgV: step3Img, ishid: true, hub: step3Hub)
        
        bottomTipContainer?.isHidden = false
        allOkOrFailStack?.isHidden = true
        retryStack?.isHidden = false
        
        configAnmateHub(animate1: false, animate2: false, animate3: false)
        
        bottomTip?.text = "ipal_step2_fail_tip".localized()
    }
    
    
    private func deal3() {
        titleLabel?.text = "ipal_connect_ing".localized()
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: false, imgName:"ipal_request_result_success",  hub: step1Hub)
        config(label: step2L, labcolor: Color.black, imgV: step2Img, ishid: false, imgName:"ipal_request_result_success", hub: step2Hub)
        config(label: step3L, labcolor: Color.black, imgV: step3Img, ishid: true, hub: step3Hub)
        
        bottomTipContainer?.isHidden = true
        allOkOrFailStack?.isHidden = true
        retryStack?.isHidden = true
        
        configAnmateHub(animate1: false, animate2: false, animate3: true)
    }
    private func suc3_1() {
        titleLabel?.text = "ipal_connect_ing".localized()
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: false, imgName:"ipal_request_result_success",  hub: step1Hub)
        config(label: step2L, labcolor: Color.black, imgV: step2Img, ishid: false,imgName:"ipal_request_result_success", hub: step2Hub)
        config(label: step3L, labcolor: Color.black, imgV: step3Img, ishid: false,imgName:"ipal_request_result_success", hub: step3Hub)
        
        bottomTipContainer?.isHidden = true
        allOkOrFailStack?.isHidden = false
        retryStack?.isHidden = true
        
        configAnmateHub(animate1: false, animate2: false, animate3: false)
        
        allOkOrFailBtn?.setTitle("Enjoy".localized(), for: .normal)
        
        
        if self.window != nil {
            
            allOkOrFailStack?.isHidden = true
            self.startAutoDissmiss()
        }
    }
    
    fileprivate func startAutoDissmiss() {
        Router.dismissVC()
    }
    
    
    
    private func fal3_1() {
        titleLabel?.text = "ipal_connect_fail".localized()
        config(label: step1L, labcolor: Color.black, imgV: step1Img, ishid: false, imgName:"ipal_request_result_success",  hub: step1Hub)
        config(label: step2L, labcolor: Color.black, imgV: step2Img, ishid: false,imgName:"ipal_request_result_success", hub: step2Hub)
        config(label: step3L, labcolor: Color.black, imgV: step3Img, ishid: false,imgName:"ipal_request_result_fail", hub: step3Hub)
        
        bottomTipContainer?.isHidden = false
        allOkOrFailStack?.isHidden = true
        retryStack?.isHidden = false
        
        configAnmateHub(animate1: false, animate2: false, animate3: false)
        
        bottomTip?.text = "ipal_step2_fail_tip".localized()
    }
    
    
    private func config(label: UILabel?, labcolor: String,
                        imgV: UIImageView?, ishid: Bool, imgName: String? = nil,
                        hub: UIActivityIndicatorView?) {
        
        label?.textColor = UIColor(hexString: labcolor)
        imgV?.isHidden = ishid
        hub?.isHidden = !ishid
        imgV?.image = UIImage(named: imgName ?? "")
    }
    
    private func configAnmateHub(animate1:Bool, animate2:Bool, animate3:Bool)
    {
        animate1 ? step1Hub?.startAnimating() : step1Hub?.stopAnimating()
        animate2 ? step2Hub?.startAnimating() : step2Hub?.stopAnimating()
        animate3 ? step3Hub?.startAnimating() : step3Hub?.stopAnimating()
    }
    
    
    
    func ncSize() -> CGSize {
        return CGSize(width: 280, height: 197)
    }
    
    func ncShowAnimate() -> Bool {
        return false
    }
}
