//
//  SwiftBTC
//
//  Created by Otto Suess on 27.02.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import web3swift

public extension String {

    func indexDistance(of character: Character) -> Int? {
        guard let index = firstIndex(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }

    func lastIndex(of string: String) -> Int? {
        guard let index = range(of: string, options: .backwards) else { return nil }
        return self.distance(from: self.startIndex, to: index.lowerBound)
    }
}

extension Data {
    public func cpToHexString() -> String {
        let array:[UInt8] = Array(self)
        return array.cpToHexString()
    }
}

extension Array where Element == UInt8 {
    public func cpToHexString() -> String {
        return `lazy`.reduce("") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }
}
