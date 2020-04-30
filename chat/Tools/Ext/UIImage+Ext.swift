







import Foundation

extension UIImage {
    func compressTo(_ expectedSizeInMb:Int) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue)  {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.25
                }
            }
        }
        
        if let data = imgData {
            return data
        }
        return nil
    }
    
    
    
    func coverToCIImage() -> UIImage? {
        guard let ci = self.ciImage else { return self }
        
        let cicontext = CIContext.init()
        guard let cgimg = cicontext.createCGImage(ci, from: (ci.extent)) else { return nil }
        
        return UIImage(cgImage: cgimg)
    }
}
