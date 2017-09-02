//
//  MapViewController.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    static weak var instance: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapViewController.instance = self
        
        let view = MapView()
        self.view = view
        
        startAnimationTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.view.setNeedsLayout()
        })
        
        view.locationButton.addTarget(self, action: #selector(locationAction), for: .touchUpInside)
        
        let kupaaGesture = UIPinchGestureRecognizer(target: self, action: #selector(kupaaAction(_:)))
        view.addGestureRecognizer(kupaaGesture)
        
        setMapType(str: Settings.mapType)
    }
    
    func setMapType(str: String) {
        if str == "標準" {
            MapView.instance?.mapType = .standard
            tanshoku(bool: false)
        }
        else if str == "航空写真" {
            MapView.instance?.mapType = .hybrid
            tanshoku(bool: false)
        }
        else if str == "国土地理院" {
            tanshoku(bool: true)
        }
    }
    
    func tanshoku(bool: Bool) {
        guard let view = self.view as? MapView else { return }
        
        if bool {
            let template = "https://cyberjapandata.gsi.go.jp/xyz/pale/{z}/{x}/{y}.png"
            let overlay = MyTileOverlay(urlTemplate: template)
            overlay.canReplaceMapContent = true
            view.add(overlay, level: .aboveLabels)
            
            // ライセンス表示
            view.licenseView.text = "国土地理院"
        } else {
            for overlay in view.overlays {
                if let overlay = overlay as? MyTileOverlay {
                    view.remove(overlay)
                }
            }
            
            // ライセンス表示を消す
            view.licenseView.text = ""
        }
    }
    
    private var timer: Timer?
    func startAnimationTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(animateAction), userInfo: nil, repeats: true)
    }
    
    private var counter = 0
    func animateAction() {
        guard let view = self.view as? MapView else { return }
        
        UIView.animate(withDuration: 0.4, animations: {
            if self.counter % 2 == 0 {
                view.centerLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8);
            } else {
                view.centerLabel.transform = CGAffineTransform.identity;
            }
        })
        
        counter += 1
    }
    
    func locationAction() {
        guard let mapView = self.view as? MapView else { return }
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            ViewUtil.alert(msg: "位置情報取得が許可されていません")
        }
        
        mapView.setCenter(mapView.userLocation.coordinate, animated: false)
    }
    
    func kupaaAction(_ gesture: UIPinchGestureRecognizer) {
        guard let mapView = self.view as? MapView else { return }
        
        if gesture.scale > 1.1 {
            if mapView.mapControlView.largerButton.isEnabled {
                mapView.mapControlView.largerAction()
            }
        }
        else if gesture.scale < 0.9 {
            if mapView.mapControlView.smallerButton.isEnabled {
                mapView.mapControlView.smallerAction()
            }
        }
    }
}
