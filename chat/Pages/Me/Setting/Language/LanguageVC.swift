//
//  Language.swift
//  chat
//
//  Created by Grand on 2019/8/28.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

class LanguageVC: BaseTableViewController {
    
    @IBOutlet weak var judgeRule: NCConfigCell!
    @IBOutlet weak var cn_zh: NCConfigCell!
    @IBOutlet weak var en_def: NCConfigCell!
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
            // Fallback on earlier versions
        }
        super.viewDidLoad()
        self.tableView.adjustFooter()
        refreshCells()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NCConfigCell,
            cell.rightOption.isHidden == true else { return }
        
        if cell == judgeRule {
            Bundle.recoveryToSystem()
        }
        else if cell == en_def {
            Bundle.setCustomLanguage(.en)
        }
        else if cell == cn_zh {
            Bundle.setCustomLanguage(.zh_Hans)
        }
        
        refreshCells()
        restartAppRoot()
    }
    
    func refreshCells() {
        
        let (language, isManual)  = Bundle.currentLanguage()
        
        if isManual {
            judgeRule.rightOption?.isHidden = true
            cn_zh.rightOption.isHidden = !(language == CustomLanguage.zh_Hans.rawValue)
            en_def.rightOption.isHidden = !(language == CustomLanguage.en.rawValue)
        }
        else {
            judgeRule.rightOption?.isHidden = false
            cn_zh.rightOption?.isHidden = true
            en_def.rightOption?.isHidden = true
        }
    }
    
    func restartAppRoot() {
        if let rootNav = Router.rootVC as? GrandNavVC {
            rootNav.switchLuguage()
        }
    }
    
}
