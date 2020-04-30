






import Foundation



public enum Bech32 {
    private static let alphabet = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
    private static let generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]

    private static func expandHumanReadablePart(_ humanReadablePart: String) -> Data {
        guard let stringBytes = humanReadablePart.data(using: .utf8) else { return Data() }
        var data = Data()

        for character in stringBytes {
            data.append(UInt8(UInt32(character) >> 5))
        }
        data.append(0)
        for character in stringBytes {
            data.append(UInt8(UInt32(character) & 31))
        }
        return data
    }

    private static func polymod(values: Data) -> Int {
        var chk = 1
        
        for p in values {
            let top = chk >> 25
            chk = (chk & 0x1ffffff) << 5 ^ Int(p)
            
            for (i, g) in Bech32.generator.enumerated() where ((top >> i) & 1) != 0 {
                chk ^= g
            }
        }
        return chk
    }

    private static func verifyChecksum(humanReadablePart: String, data: Data) -> Bool {
        return polymod(values: expandHumanReadablePart(humanReadablePart) + data) == 1
    }

    private static func createChecksum(humanReadablePart: String, data: Data) -> Data {
        let values = expandHumanReadablePart(humanReadablePart) + data + Data(Array(repeating: UInt8(0), count: 6))
        let mod: Int = polymod(values: values) ^ 1

        var result = Data()
        for index in 0..<6 {
            result.append(UInt8((mod >> UInt(5 * (5 - index))) & 31))
        }
        return result
    }

    private static func hasValidCharacters(_ bechString: String) -> Bool {
        guard let stringBytes = bechString.data(using: .utf8) else { return false }

        var hasLower = false
        var hasUpper = false

        for character in stringBytes {
            let code = UInt32(character)
            if code < 33 || code > 126 {
                return false
            } else if code >= 97 && code <= 122 {
                hasLower = true
            } else if code >= 65 && code <= 90 {
                hasUpper = true
            }
        }

        return !(hasLower && hasUpper)
    }

    public static func decode(_ bechString: String, limit: Bool = true) -> (humanReadablePart: String, data: Data)? {
        guard hasValidCharacters(bechString) else { return nil }

        let bechString = bechString.lowercased()
        guard let pos = bechString.lastIndex(of: "1")?.encodedOffset else { return nil }

        if pos < 1 || pos + 7 > bechString.count || (limit && bechString.count > 90) {
            return nil
        }

        let humanReadablePart = String(bechString.prefix(pos))
        let dataPart = bechString.suffix(bechString.count - humanReadablePart.count - 1)

        var data = Data()
        for character in dataPart {
            guard let distance = Bech32.alphabet.indexDistance(of: character) else { return nil }
            data.append(UInt8(distance))
        }

        if !verifyChecksum(humanReadablePart: humanReadablePart, data: data) {
            return nil
        }

        return (humanReadablePart, Data(data[..<(data.count - 6)]))
    }

    private static func toChars(data: Data) -> String {
        return data.reduce("") {
            let index = Bech32.alphabet.index(Bech32.alphabet.startIndex, offsetBy: Int($1))
            return $0 + String(Bech32.alphabet[index])
        }
    }

    public static func encode(humanReadablePart: String, data: Data) -> String {
        let checksum = Bech32.createChecksum(humanReadablePart: humanReadablePart, data: data)
        let combined = data + checksum

        return humanReadablePart + "1" + Bech32.toChars(data: combined)
    }
    
    
    

    public static func parseFallbackAddress(data: Data) -> String? {
        guard data.count >= 2 else {
            return nil
        }
        guard let converted = data.convertBits(fromBits: 8, toBits: 5, pad: true) else {
            return nil
        }
        let address = Bech32.encode(humanReadablePart: "nch", data: converted)
        return address;
    }
}



extension Bech32 {
    
    
}


extension Data {
    
    
    func convertBits(fromBits: Int, toBits: Int, pad: Bool) -> Data? {
        var acc: Int = 0
        var bits: Int = 0
        var result = Data()
        let maxv: Int = (1 << toBits) - 1
        
        for value in self {
            if value < 0 || (value >> fromBits) != 0 {
                return nil
            }
            
            acc = (acc << fromBits) | Int(value)
            bits += fromBits
            
            while bits >= toBits {
                bits -= toBits
                result.append(UInt8((acc >> bits) & maxv))
            }
        }
        
        if pad {
            if bits > 0 {
                result.append(UInt8((acc << (toBits - bits)) & maxv))
            }
        } else if bits >= fromBits || ((acc << (toBits - bits)) & maxv) != 0 {
            return nil
        }
        
        return result
    }
}
