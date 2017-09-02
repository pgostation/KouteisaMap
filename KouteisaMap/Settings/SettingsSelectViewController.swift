//
//  SettingsSelectViewController.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/09/02.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

class SettingsSelectViewController: UITableViewController {
    private var mySource: SettingsSelectViewTable
    
    init(items: [String], selected: String, callback: @escaping (String)->Void) {
        mySource = SettingsSelectViewTable(items: items, selected: selected, callback: callback)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = SettingsSelectView()
        self.view = view
        
        view.delegate = self
        view.dataSource = mySource
    }
    
    // 選択時の処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str = mySource.items[indexPath.item]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        mySource.callback(str)
        
        // 表示更新
        mySource = SettingsSelectViewTable(items: mySource.items, selected: str, callback: mySource.callback)
        let view = self.view as! SettingsSelectView
        view.dataSource = mySource
        view.reloadData()
    }
}

class SettingsSelectView: UITableView {
}

class SettingsSelectViewTable: NSObject, UITableViewDataSource {
    let items: [String]
    private let selected: String
    let callback: (String)->Void
    
    init(items: [String], selected: String, callback: @escaping (String)->Void) {
        self.items = items
        self.selected = selected
        self.callback = callback
        
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // セル表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsLinks") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SettingsLinks")
        
        cell.textLabel?.text = items[indexPath.item]
        
        if items[indexPath.item] == selected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
