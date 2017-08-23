//
//  ControlView.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

class ControlView: UIView {
    let menuButton = UIButton() // メニュー表示ボタン
    
    private var isOpenMenu = false
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addSubview(menuButton)
        
        // ボタン設定
        self.menuButton.addTarget(self, action: #selector(menuAction), for: .touchUpInside)
        
        // サブビューの設定
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        let buttonWidth: CGFloat = 48
        
        self.clipsToBounds = true
        
        self.menuButton.backgroundColor = UIColor.orange
        self.menuButton.layer.cornerRadius = buttonWidth / 2
        self.menuButton.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.superview?.frame ?? UIScreen.main.bounds
        
        let buttonWidth: CGFloat = 48
        
        self.frame = CGRect(x: 0,
                            y: bounds.height - buttonWidth - 10,
                            width: bounds.width,
                            height: buttonWidth)
        
        self.menuButton.frame = CGRect(x: self.frame.width / 2 - buttonWidth / 2,
                                       y: self.frame.height - buttonWidth,
                                       width: buttonWidth,
                                           height: buttonWidth)
    }
    
    // 設定画面に移動
    func menuAction() {
        let vc = SettingsViewController()
        MapViewController.instance?.present(vc, animated: true, completion: nil)
    }
}
