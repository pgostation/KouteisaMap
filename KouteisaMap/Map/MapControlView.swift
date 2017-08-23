//
//  MapControlView.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

// 地図の拡大縮小ボタン

import UIKit
import MapKit

class MapControlView: UIView {
    let largerButton = UIButton() // 拡大ボタン
    let smallerButton = UIButton() // 広域ボタン
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addSubview(largerButton)
        self.addSubview(smallerButton)
        
        // ボタン設定
        self.largerButton.addTarget(self, action: #selector(largerAction), for: .touchUpInside)
        self.smallerButton.addTarget(self, action: #selector(smallerAction), for: .touchUpInside)
        
        // サブビューの設定
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        let buttonWidth: CGFloat = 40
        
        self.clipsToBounds = true
        
        self.largerButton.setTitle("＋", for: .normal)
        self.largerButton.backgroundColor = UIColor.gray
        self.largerButton.layer.cornerRadius = buttonWidth / 2
        self.largerButton.clipsToBounds = true
        
        self.smallerButton.setTitle("ー", for: .normal)
        self.smallerButton.backgroundColor = UIColor.gray
        self.smallerButton.layer.cornerRadius = buttonWidth / 2
        self.smallerButton.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.superview?.frame ?? UIScreen.main.bounds
        
        self.frame = CGRect(x: bounds.width - 45,
                            y: bounds.height - 95,
                            width: 40,
                            height: 90)
        
        let buttonWidth: CGFloat = 40
        
        self.largerButton.frame = CGRect(x: 0,
                                         y: 0,
                                         width: buttonWidth,
                                         height: buttonWidth)
        
        self.smallerButton.frame = CGRect(x: 0,
                                          y: 50,
                                          width: buttonWidth,
                                          height: buttonWidth)
        
    }
    
    // 拡大
    func largerAction() {
        guard let mapView = MapView.instance else { return }
        
        var region = mapView.region
        region.span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2, longitudeDelta: region.span.longitudeDelta / 2)
        mapView.setRegion(region, animated: true)
        
        if mapView.region.span.longitudeDelta < 0.01 {
            self.largerButton.isEnabled = false
            self.largerButton.alpha = 0.5
        }
        self.smallerButton.isEnabled = true
        self.smallerButton.alpha = 1
    }
    
    // 縮小
    func smallerAction() {
        guard let mapView = MapView.instance else { return }
        
        var region = mapView.region
        region.span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2, longitudeDelta: region.span.longitudeDelta * 2)
        mapView.setRegion(region, animated: true)
        
        if mapView.region.span.longitudeDelta > 0.5 {
            self.smallerButton.isEnabled = false
            self.smallerButton.alpha = 0.5
        }
        self.largerButton.isEnabled = true
        self.largerButton.alpha = 1
    }
}
