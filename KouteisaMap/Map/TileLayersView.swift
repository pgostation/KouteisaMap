//
//  TileLayersView.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit
import MapKit

class TileLayersView: UIView {
    var tileColors: [[UIColor]] = []
    var lastTileSize: CGFloat = 0
    var topLeftCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var selectedUid = ""
    
    init(frame: CGRect = UIScreen.main.bounds, tileSize: CGFloat) {
        super.init(frame: frame)
        
        sizeChange(tileSize: tileSize)
        
        self.isUserInteractionEnabled = false
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sizeChange(tileSize: CGFloat) {
        if abs(self.lastTileSize - tileSize) < 0.1 { return }
        self.lastTileSize = tileSize
        
        objc_sync_enter(self)
        
        tileColors = []
        
        for _ in 0..<Int(self.frame.height / tileSize) + 1 {
            var tileColor: [UIColor] = []
            for _ in 0..<Int(self.frame.width / tileSize) + 1 {
                tileColor.append(UIColor.clear)
            }
            tileColors.append(tileColor)
        }
        
        objc_sync_exit(self)
        
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        // 標高を描画
        objc_sync_enter(self)
        
        var rect = CGRect(x: 0, y: 0, width: self.lastTileSize, height: self.lastTileSize)
        
        for y in 0..<tileColors.count {
            let tileColor = tileColors[y]
            for x in 0..<tileColor.count {
                tileColor[x].setFill()
                UIRectFill(rect)
                rect.origin.x += self.lastTileSize
            }
            rect.origin.x = 0
            rect.origin.y += self.lastTileSize
        }
        
        objc_sync_exit(self)
    }
}
