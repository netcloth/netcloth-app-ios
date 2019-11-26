







import Foundation

protocol DataSourceInterface {
    func onForceReload(data:[AnyObject]?)
    func onPendingReload(data: [AnyObject]?)
}
