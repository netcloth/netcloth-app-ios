







import Foundation

extension NSDecimalNumber {
    
    func formatterToString(decimals: Int = 12) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimals
        formatter.roundingMode = .floor
        return formatter.string(from: self) ?? "0"
    }
}
