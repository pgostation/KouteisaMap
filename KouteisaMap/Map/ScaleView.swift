//
//  ScaleView.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/26.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ScaleView: UIView {
    let leftView = UIView()
    let rightView = UIView()
    let lineView = UIView()
    let lengthLabel = UILabel()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addSubview(leftView)
        self.addSubview(rightView)
        self.addSubview(lineView)
        self.addSubview(lengthLabel)
        
        // サブビューの設定
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        leftView.backgroundColor = UIColor.black
        rightView.backgroundColor = UIColor.black
        lineView.backgroundColor = UIColor.black
        
        lengthLabel.font = UIFont(name: "Avenir-Black", size: 16)
        lengthLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let mapView = MapView.instance else { return }
        
        let (lengthString, viewWidth) = getLength(mapView: mapView)
        
        self.lengthLabel.text = lengthString
        
        self.leftView.frame = CGRect(x: 0,
                                     y: 2,
                                     width: 3,
                                     height: self.frame.height - 2)
        
        self.rightView.frame = CGRect(x: viewWidth,
                                     y: 2,
                                     width: 3,
                                     height: self.frame.height - 2)
        
        self.lineView.frame = CGRect(x: 0,
                                      y: self.frame.height - 3,
                                      width: viewWidth + 3,
                                      height: 3)
        
        self.lengthLabel.frame = CGRect(x: 3,
                                     y: 0,
                                     width: viewWidth - 3,
                                     height: self.frame.height)
    }
    
    private func getLength(mapView: MKMapView) -> (String, CGFloat) {
        let delta = mapView.region.span.longitudeDelta // 画面の横幅あたりの経度
        let deltaPerPixel = delta / Double(mapView.frame.width) // 1ピクセルあたりの経度
        
        let loc1 = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let loc2 = CLLocation(latitude: mapView.centerCoordinate.latitude + deltaPerPixel, longitude: mapView.centerCoordinate.longitude)
        var lengthPerPixel = loc2.distance(from: loc1) // 1ピクセルあたりの長さ(メートル)
        
        var rate = Double(1.0)
        while lengthPerPixel > 10 {
            rate *= 10
            lengthPerPixel /= 10
        }
        if lengthPerPixel > 5 {
            rate *= 5
            lengthPerPixel /= 5
        }
        if lengthPerPixel > 3 {
            rate *= 3
            lengthPerPixel /= 3
        }
        if lengthPerPixel > 2 {
            rate *= 2
            lengthPerPixel /= 2
        }
        
        let viewWidth = CGFloat(100 / lengthPerPixel)
        let lengthString = 100 * rate >= 1000 ? "\(Int(100 * rate / 1000))km" : "\(Int(100 * rate))m"
        
        print("#### --")
        print("#### viewWidth=\(viewWidth)")
        print("#### rate=\(rate)")
        print("#### \(Double(viewWidth) * loc2.distance(from: loc1))")
        
        return (lengthString, viewWidth)
    }
}
