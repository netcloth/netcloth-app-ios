







import Foundation

let InputAtStartChar = "@"
let InputAtEndChar = "\u{2004}"
let FakeAtALLPubkey = "041232"

class InputAtItem: NSObject {
    var name: String?
    var hexPubkey: String?
}

class InputAtCache: NSObject {
    fileprivate var list: [InputAtItem] = []
    
    
    func allAtPubkey(ofSenderText: String) -> [String]? {
        guard let names = matchNameString(ofSenderText: ofSenderText) else {
            return nil
        }
        var  pubkeys = [String]()
        for item in names {
            if let find = findItem(byName: item),
                let pk = find.hexPubkey {
                pubkeys.append(pk)
            }
        }
        return pubkeys
    }
    
    func clean() {
        self.list.removeAll()
    }
    
    func add(atItem: InputAtItem) {
        list.append(atItem)
    }
    
    func remove(atItem: InputAtItem) {
        list = list.filter { (item) -> Bool in
            if item.name == atItem.name {
                return false
            }
            return true
        }
    }
    
    func findItem(byName: String) -> InputAtItem? {
        
        for item in list {
            if item.name == byName {
                return item
            }
        }
        
        return nil
    }
    
    
    fileprivate func matchNameString(ofSenderText: String) -> [String]? {
        let p = "\(InputAtStartChar)([^\(InputAtEndChar)]+\(InputAtEndChar))"
        let regex = try? NSRegularExpression(pattern: p, options: NSRegularExpression.Options.caseInsensitive)
        if let t = ofSenderText as? NSString {
            let result = regex?.matches(in: t as String,
                                        options: NSRegularExpression.MatchingOptions.init(rawValue: 0),
                                        range: NSRange(location: 0, length: t.length))
            
            if let r = result {
                var  matchs = [String]()
                for item in r {
                    var name: NSString = t.substring(with: item.range) as NSString
                    name = name.substring(from: 1) as NSString
                    name = name.substring(to: name.length - 1) as NSString
                    matchs.append(name as String)
                }
                return matchs
            }
        }
        return nil
    }
}
