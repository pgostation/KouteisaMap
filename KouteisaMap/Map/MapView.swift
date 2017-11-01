//
//  MapView.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/09/02.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit
import MapKit

class MapView: MKMapView {
    static weak var instance: MapView?
    private let myDelegate = MapViewDelegate()
    let licenseView = UILabel()
    let tileLayersView = TileLayersView(tileSize: 20)
    let scaleView = ScaleView()
    let controlView = ControlView()
    let mapControlView = MapControlView()
    let mapInfoView = MapInfoView()
    let centerLabel = UILabel()
    let locationButton = UIButton()
    let locationManager = CLLocationManager()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        MapView.instance = self
        
        self.addSubview(tileLayersView)
        DispatchQueue.main.async { // 遅いiPadでも表示できるように、細工している
            DispatchQueue.main.async {
                self.addSubview(self.licenseView)
                self.addSubview(self.scaleView)
                self.addSubview(self.mapInfoView)
                self.addSubview(self.centerLabel)
                self.addSubview(self.controlView)
                self.addSubview(self.mapControlView)
                self.addSubview(self.locationButton)
                
                self.layoutSubviews()
            }
        }
        
        // MapView関連の設定
        mapSetUp()
        
        // サブビューの設定
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MapView関連の設定
    private func mapSetUp() {
        self.delegate = myDelegate
        
        // 表示範囲を設定
        let coord = CLLocationCoordinate2D(latitude: 35.681167, longitude: 139.767052)
        let span = MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coord, span: span)
        self.setRegion(region, animated: false)
        
        // プロパティ設定
        self.isRotateEnabled = false
        self.isZoomEnabled = false
        self.isPitchEnabled = false
        
        // 位置表示
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        self.showsUserLocation = true
    }
    
    // サブビューの設定
    private func setUp() {
        self.licenseView.text = ""
        self.licenseView.font = UIFont.systemFont(ofSize: 14)
        self.licenseView.textAlignment = .center
        
        self.centerLabel.text = "＋"
        self.centerLabel.font = UIFont.systemFont(ofSize: 28)
        self.centerLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.7)
        self.centerLabel.textAlignment = .center
        
        self.locationButton.setTitle("現在地へ", for: .normal)
        self.locationButton.backgroundColor = UIColor.gray
        self.locationButton.layer.cornerRadius = 36 / 2
        self.locationButton.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.controlView.setNeedsLayout()
        self.mapControlView.setNeedsLayout()
        
        let bounds = self.frame
        
        let infoViewWidth: CGFloat = UIScreen.main.bounds.width <= 320 ? 120 : 135
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        
        self.licenseView.frame = CGRect(x: bounds.width - 80,
                                        y: bounds.height - 15,
                                        width: 85,
                                        height: 15)
        
        self.mapInfoView.frame = CGRect(x: bounds.width - infoViewWidth,
                                        y: statusBarHeight + 5,
                                        width: infoViewWidth,
                                        height: 26)
        
        self.centerLabel.frame = CGRect(x: bounds.width / 2 - 16,
                                        y: bounds.height / 2 - 6,
                                        width: 32,
                                        height: 32)
        
        self.locationButton.frame = CGRect(x: 5,
                                           y: statusBarHeight + 5,
                                           width: 80,
                                           height: 36)
        
        self.scaleView.frame = CGRect(x: 5,
                                      y: bounds.height - 50,
                                      width: 150,
                                      height: 20)
    }
    
    func refresh() {
        self.myDelegate.tileRefresh(mapView: self, force: false)
    }
}
