//
//  SettingsViewController.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit
import MapKit

enum SettingsEnum: String {
    case search = "地名検索"
    case shareApp = "Twitter等でアプリを紹介する"
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
        
        self.title = "設定"
        
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
            searchAction()
        case .shareApp:
            shareApp()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchAction() {
        ViewUtil.textInput(msg: "地名を入力してください", defaultText: "", okName: "検索", callback: { text in
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = text
            
            MKLocalSearch(request: request).start(completionHandler: {
                (response: MKLocalSearchResponse?, error: Error?) in
                
                if let error = error {
                    print("searchAction(): \(error.localizedDescription)")
                    return
                }
                
                if response?.mapItems.count == 0 {
                    ViewUtil.alert(msg: "見つかりませんでした")
                    return
                }
                
                if let item = response?.mapItems.first {
                    self.view.alpha = 0.5
                    
                    MapView.instance?.setCenter(item.placemark.coordinate, animated: false)
                    
                    DispatchQueue.main.async {
                        self.close()
                    }
                }
            })
        })
    }
    
    // 共有パネルを表示
    func shareApp() {
        let shareText = "色で高低差が分かる iPhoneアプリ「Rainbow Map」"
        let shareWebsite = URL(string: "itms-apps://itunes.apple.com/app/####")!
        
        let activityItems: [Any] = [shareText, shareWebsite]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivityType.addToReadingList,
            UIActivityType.saveToCameraRoll,
            UIActivityType.print
        ]
        activityViewController.excludedActivityTypes = excludedActivityTypes
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}

class SettingsView: UITableView {
}

class SettingsTable: NSObject, UITableViewDataSource {
    var tableList:[SettingsEnum] = [.search, .shareApp]
    
    override init() {
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
            cell.accessoryType = .disclosureIndicator
        case .shareApp:
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}
