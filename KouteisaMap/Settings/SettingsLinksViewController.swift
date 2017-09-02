//
//  SettingsLinksViewController.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/26.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

class SettingsLinksViewController: UITableViewController {
    private let mySource: SettingsLinksViewTable
    
    init(items: [String], subtitles: [String], urls: [URL]) {
        mySource = SettingsLinksViewTable(items: items, subtitles: subtitles, urls: urls)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "おすすめアプリ"
        
        let view = SettingsLinksView()
        self.view = view
        
        view.delegate = self
        view.dataSource = mySource
    }
    
    // 選択時の処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = mySource.urls[indexPath.item]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        Settings.peteLink(viewController: self.navigationController!, url: url)
    }
}

class SettingsLinksView: UITableView {
}

class SettingsLinksViewTable: NSObject, UITableViewDataSource {
    private let items:[String]
    private let subtitles:[String]
    let urls:[URL]
    
    init(items: [String], subtitles: [String], urls: [URL]) {
        self.items = items
        self.subtitles = subtitles
        self.urls = urls
        
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // セル表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsLinks") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SettingsLinks")
        
        cell.textLabel?.text = items[indexPath.item]
        cell.detailTextLabel?.text = subtitles[indexPath.item]
        
        return cell
    }
}
