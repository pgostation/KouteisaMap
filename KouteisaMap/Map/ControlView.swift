//
//  ControlView.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

class ControlView: UIView, UIPopoverPresentationControllerDelegate {
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
        let buttonWidth: CGFloat = 36
        
        self.clipsToBounds = true
        
        self.menuButton.setTitle("機能", for: .normal)
        self.menuButton.backgroundColor = UIColor.gray
        self.menuButton.layer.cornerRadius = buttonWidth / 2
        self.menuButton.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //let bounds = self.superview?.frame ?? UIScreen.main.bounds
        
        self.frame = CGRect(x: 100,
                            y: 25,
                            width: 80,
                            height: 36)
        
        self.menuButton.frame = CGRect(x: 0,
                                       y: 0,
                                       width: 70,
                                       height: 36)
    }
    
    // 設定画面に移動
    func menuAction() {
        let vc = SettingsViewController()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 300, height: 300)
            vc.popoverPresentationController?.sourceView = self
            vc.popoverPresentationController?.sourceRect = self.menuButton.frame
            vc.popoverPresentationController?.permittedArrowDirections = .any
            vc.popoverPresentationController?.delegate = self
        }
        
        MapViewController.instance?.present(vc, animated: true, completion: nil)
    }
}
