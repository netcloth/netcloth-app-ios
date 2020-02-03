  
  
  
  
  
  
  

import UIKit

class UploadProgressView: AlertView, NCAlertInterface {
    private var progressV: LXWaveProgressView?
    @IBOutlet var containV: UIView?
    
    override func layoutSubviews() {
        if progressV == nil {
            progressV = LXWaveProgressView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            containV?.addSubview(progressV!)
        }
    }
    
    var progress: Double = 0 {
        didSet {
            progressV?.progress = CGFloat(self.progress)
        }
    }
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 181)
    }
}
