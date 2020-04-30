







import UIKit
import web3swift
import FCFileManager

enum KSError: Error {
    case unknow
}

@objc public
class NCKeyStore: NSObject {
    
    private var _keystore: EthereumKeystoreV3?
    private var keystore: EthereumKeystoreV3? {
        get {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            return _keystore
        }
        set {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            _keystore = newValue
        }
    }
    
    @objc static public var shared = NCKeyStore()
    
    
    @objc public func login(_ uid:Int, pwd: String) throws {
        do {
            let path = self.pathForKeystore(uid)
            
            if let ksjson = FCFileManager.readFileAtPath(as: path) {
                print("keystore path \(path)  content \(ksjson)")
                _ = try CPWalletWraper.decodeKeystore(ksjson, password: pwd)
                
                self.keystore = EthereumKeystoreV3(ksjson)
                if self.keystore == nil {
                    throw KSError.unknow
                }
            }
            else {
                throw KSError.unknow
            }
        }
        catch {
            throw error
        }
    }
    
    @objc public func register(originPrivateKey:Data, pwd: String, uid: Int) throws {
        do {
            let ksjson = try CPWalletWraper.encodeKeystore(originPrivateKey, exportPwd: pwd)
            try saveKeystore(ksjson, uid: uid)
        }
        catch {
            throw error
        }
    }
    
    @objc public func changeLoginUser(oldPwd: String,
                                              toNewPwd nPwd:String,
                                              uid: Int) throws {
        do {
            let v3KeyStore = self.keystore
            let orpk = try nsdataPrikeyOfLoginUser(oldPwd)
            try v3KeyStore?.regenerate(oldPassword: oldPwd, newPassword: nPwd)
            
            let ksjson = try CPWalletWraper.encodeKeystore(orpk, exportPwd: nPwd)
            try saveKeystore(ksjson, uid: uid)
        }
        catch {
            throw error
        }
    }
    
    @objc public func nsdataPrikeyOfLoginUser(_ pwd: String) throws -> Data {
        do {
            let v3KeyStore = self.keystore
            if let address = v3KeyStore?.addresses?.first {
                if let data =  try v3KeyStore?.UNSAFE_getPrivateKeyData(password: pwd, account: address) {
                    return data
                }
            }
            throw KSError.unknow
        }
        catch {
            throw error
        }
    }
    
    
    func pathForKeystore(_ uid: Int) -> String {
        return FCFileManager.pathForDocumentsDirectory(withPath: "\(uid)/user.data")
    }
    
    
    func saveKeystore(_ ksjson: String, uid: Int) throws {
        let path = self.pathForKeystore(uid)
        if FCFileManager.writeFile(atPath: path, content: ksjson as NSString) == false {
            throw KSError.unknow
        }
    }
}

@objc public
class CPWalletWraper: NSObject {
    
    @objc public
    static func decodeKeystore(_ keystore: String, password: String) throws -> Data {
        do {
            let v3KeyStore = try EthereumKeystoreV3(keystore)
            if let address = v3KeyStore?.addresses?.first {
                if let data =  try v3KeyStore?.UNSAFE_getPrivateKeyData(password: password, account: address) {
                    print("\(data) count \(data.count)")
                    return data
                }
            }
            throw KSError.unknow
        }
        catch {
            throw error
        }
    }
    
    @objc public
    static func encodeKeystore(_ originPrivateKey:Data, exportPwd: String) throws  -> String {
        do {
            let v3KeyStore = try EthereumKeystoreV3(privateKey: originPrivateKey, password: exportPwd, aesMode: "aes-128-ctr")
            if let data = try v3KeyStore?.serialize() {
                return String(data: data , encoding: .utf8) ?? ""
            }
            return ""
        }
        catch {
            throw error
        }
    }
    
    
    @objc public
    static func verifyPrivateKey(privateKey: Data) -> Bool {
        let result =
            SECP256K1.verifyPrivateKey(privateKey: privateKey)
        return result
    }
}
