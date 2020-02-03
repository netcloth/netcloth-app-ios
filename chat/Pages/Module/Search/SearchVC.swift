  
  
  
  
  
  
  

import UIKit

class SearchVC: BaseViewController ,
UISearchBarDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating {
    
    var resultVC: (UIViewController&Cell)?   
    var searchTextChange: ((_ input: String?, _ callBack: @escaping (Any) -> Void) -> Void)?
    
    @IBOutlet weak var searchContainerView: UIView?
    fileprivate var searchViewController: UISearchController?
    
    let disbag = DisposeBag()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        assert(resultVC != nil)
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchViewController?.isActive = true
        searchViewController?.searchBar.becomeFirstResponder()
    }
    
    func configUI() {
          
        let result = resultVC!
        
        let searchVC = UISearchController(searchResultsController: result)
        self.searchViewController = searchVC
        searchVC.delegate = self
        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = false
        searchVC.hidesNavigationBarDuringPresentation = false
        searchVC.dimsBackgroundDuringPresentation = false
        
        self.definesPresentationContext = false
        
        
        let searchBar = self.searchViewController!.searchBar
        self.searchContainerView?.addSubview(searchBar)
        searchBar.frame = self.searchContainerView!.bounds
        searchBar.placeholder = "Search".localized()
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
    }
}

extension SearchVC {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        Router.dismissVC()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let input = searchController.searchBar.text
        self.searchTextChange?(input) {
            self.resultVC?.reloadData(data: $0)
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
    }
}
