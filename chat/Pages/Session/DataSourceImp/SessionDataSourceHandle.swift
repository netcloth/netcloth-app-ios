







import Foundation

class SessionDataSourceHandle: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private var delegateContainer = TableDelegateContainer()
    unowned var tableView: UITableView
    required init(table: UITableView, owner: NSObject) {
        tableView = table
        super.init()
        
        delegateContainer.add(delegate: owner)
        delegateContainer.add(delegate: self)
        setup()
    }
    
    fileprivate func setup() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
