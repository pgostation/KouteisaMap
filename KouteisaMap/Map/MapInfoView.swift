//
//  MapInfoView.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

class MapInfoView: UIView {
    let heightLabel = UILabel()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addSubview(self.heightLabel)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        let fontSize: CGFloat = UIScreen.main.bounds.width <= 320 ? 18 : 20
        
        self.heightLabel.text = ""
        self.heightLabel.font = UIFont(name: "Avenir-Black", size: fontSize)
        self.heightLabel.textColor = UIColor.white
        self.heightLabel.textAlignment = .right
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.frame
        
        self.heightLabel.frame = CGRect(x: 0,
                                        y: 2,
                                        width: bounds.width - 5,
                                        height: 24)
    }
}
