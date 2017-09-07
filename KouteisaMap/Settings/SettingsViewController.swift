//
//  SettingsViewController.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

enum SettingsEnum: String {
    case search = "地名検索"
    case mapType = "地図の種類"
    case sensitiveMode = "表示モード"
    case shareApp = "Twitter等でアプリを紹介する"
    case peteLink = "おすすめアプリ"
}

class SettingsViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewControllers([SettingsTableViewController()], animated: false)
    }
}

class SettingsTableViewController: UITableViewController {
    private let mySource = SettingsTable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "機能"
        
        let leftButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = leftButton
        
        let view = SettingsView()
        self.view = view
        
        view.delegate = self
        view.dataSource = mySource
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 選択時の処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = mySource.tableList[indexPath.item]
        switch item {
        case .search:
            Settings.searchAction(viewController: self)
        case .mapType:
            let childViewController = SettingsSelectViewController(
                items: ["標準", "航空写真", "国土地理院"],
                selected: Settings.mapType,
                callback: { value in
                    Settings.mapType = value
            })
            childViewController.title = item.rawValue
            self.navigationController?.pushViewController(childViewController, animated: true)
        case .sensitiveMode:
            let childViewController = SettingsSelectViewController(
                items: ["微小高低差", "標準", "山間部"],
                selected: Settings.sensitiveMode,
                callback: { value in
                    Settings.sensitiveMode = value
            })
            childViewController.title = item.rawValue
            self.navigationController?.pushViewController(childViewController, animated: true)
        case .shareApp:
            Settings.shareApp(viewController: self)
        case .peteLink:
            let peteAppPage = URL(string: "itms-apps://itunes.apple.com/app/id1184708726")!
            let childViewController = SettingsLinksViewController(
                items: ["Pete(ピート)"],
                subtitles: ["位置情報と地図とコミュニケーションのアプリ"],
                urls: [peteAppPage])
            self.navigationController?.pushViewController(childViewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class SettingsView: UITableView {
}

class SettingsTable: NSObject, UITableViewDataSource {
    let tableList:[SettingsEnum]
    
    override init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableList = [.search,
                         .mapType,
                         .sensitiveMode,
                         .peteLink]
        } else {
            tableList = [.search,
                         .mapType,
                         .sensitiveMode,
                         .shareApp,
                         .peteLink]
        }
        
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    // セル表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Settings") ?? UITableViewCell(style: .value1, reuseIdentifier: "Settings")
        let item = tableList[indexPath.item]
        cell.textLabel?.text = item.rawValue
        cell.detailTextLabel?.text = ""
        
        switch item {
        case .search:
            break
        case .mapType:
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = Settings.mapType
        case .sensitiveMode:
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = Settings.sensitiveMode
        case .shareApp:
            break
        case .peteLink:
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}
