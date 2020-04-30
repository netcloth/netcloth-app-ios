//
//  NetWork.swift
//  chat
//
//  Created by Grand on 2019/8/13.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation
import Alamofire

extension AFDataResponse {
    func isValid() -> Bool {
        return (self.response?.statusCode ?? 0) >= 200 && (self.response?.statusCode ?? 0) <= 299
    }
}

enum NW {
    
    //json
    static func requestUrl(path:String,
                           method: HTTPMethod = .get,
                           para:Parameters? = nil,
                           complete: ((_ success:Bool, _ value:Any?) -> Void)? = nil) {
        
        AF.request(path, method: method, parameters: para).responseJSON { ( res:AFDataResponse<Any>) in
            guard let cb = complete else {
                return
            }
            cb(res.value != nil && res.isValid(), res.value)
        }
    }
    
    static func getJsonUrl(path:String,
                           method: HTTPMethod = .get,
                           para:Parameters? = nil,
                           complete: @escaping ((_ success:Bool, _ value:Any?) -> Void)) {
        
        AF.request(path, method: method, parameters: para).responseJSON { ( res:AFDataResponse<Any>) in
            let cb = complete
            cb(res.value != nil && res.isValid(), res.value)
        }
    }
    
    /// get origin data
    static func getDataUrl(path:String,
                           method: HTTPMethod = .get,
                           para:Parameters? = nil,
                           complete: ((_ success:Bool, _ value:Any?) -> Void)? = nil) {
        
        AF.request(path, method: method, parameters: para).responseData { (res) in
            guard let cb = complete else {
                return
            }
            cb(res.value != nil && res.isValid() , res.data)
        }
    }
    
    
    //upload file
    
    /// <#Description#>
    /// - Parameter data: <#data description#>
    /// - Parameter fileName: <#fileName description#>
    /// - Parameter toUrl: <#toUrl description#>
    /// - Parameter complete: <#complete description#>
    /// - Parameter uploadProgress: like 0.1
    static func uploadData(data: Data,
                           toUrl: String,
                           complete: ((_ success:Bool, _ value:Any?) -> Void)? = nil,
                           uploadProgress: ((Double) -> Void)? = nil ) {
        
        
        let request =
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: "uploadfile", fileName: "uploadfile", mimeType: "*/*")
        }, to: toUrl).responseJSON { response in
            
            guard let cb = complete else {
                return
            }
            cb(response.value != nil && response.isValid(), response.value)
        }
        
        if uploadProgress != nil {
            request.uploadProgress { (progress) in
                uploadProgress!(progress.fractionCompleted)
            }
        }
    }
}

extension NW {
    //MARK:- upload Body
    static func uploadHttp(body: Data,
                           toUrl: String,
                           method: String? = "POST",
                           headers: HTTPHeaders? = nil,
                           complete: ((_ success:Bool, _ value:Data?) -> Void)? = nil) {
        let rv =  method?.uppercased() ?? "POST"
        let method_a = Alamofire.HTTPMethod(rawValue:rv)
        
        AF.upload(body, to: toUrl, method: method_a, headers: headers).responseData { (res) in
            guard let cb = complete else {
                return
            }
            cb(res.isValid(), res.data)
        }
    }
}
