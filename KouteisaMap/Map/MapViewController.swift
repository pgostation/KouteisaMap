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
}

class MapView: MKMapView {
    static weak var instance: MapView?
    private let myDelegate = MapViewDelegate()
    let tileLayersView = TileLayersView(tileSize: 20)
    let controlView = ControlView()
    let mapControlView = MapControlView()
    let mapInfoView = MapInfoView()
    let centerLabel = UILabel()
    let locationManager = CLLocationManager()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        MapView.instance = self
        
        self.addSubview(tileLayersView)
        self.addSubview(mapInfoView)
        self.addSubview(centerLabel)
        self.addSubview(controlView)
        self.addSubview(mapControlView)
        
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
        self.centerLabel.text = "○"
        self.centerLabel.font = UIFont.systemFont(ofSize: 24)
        self.centerLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.7)
        self.centerLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.controlView.setNeedsLayout()
        self.mapControlView.setNeedsLayout()
        
        let bounds = self.frame
        
        let infoViewWidth: CGFloat = UIScreen.main.bounds.width <= 320 ? 130 : 145
        
        self.mapInfoView.frame = CGRect(x: bounds.width - infoViewWidth,
                                        y: 25,
                                        width: infoViewWidth,
                                        height: 26)
        
        self.centerLabel.frame = CGRect(x: bounds.width / 2 - 12,
                                        y: bounds.height / 2 - 2,
                                        width: 24,
                                        height: 24)
    }
    
    func refresh() {
        self.myDelegate.tileRefresh(mapView: self, force: false)
    }
}

class MapViewDelegate: NSObject, MKMapViewDelegate {
    private func getTileXY(zoom: Int, coord: CLLocationCoordinate2D) -> (Double, Double) {
        let n: Double = pow(2, Double(zoom))
        let xTile = (Double(coord.longitude) + 180) / 360 * n
        let lat_rad = Double(coord.latitude) * Double.pi / 180
        let yTile = ( 1 - ( log(tan(lat_rad) + 1 / (cos(lat_rad))) / Double.pi ) ) * n / 2
        return (xTile, yTile)
    }
    
    private var timer: Timer?
    private var isBusy = false
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.tileRefresh(mapView: mapView, force: false)
        // 最大30fpsで更新
        self.timer = Timer.scheduledTimer(timeInterval: 0.033, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func timerAction() {
        guard let mapView = MapView.instance else { return }
        
        if Chiriin.isBusy() { return }
        self.tileRefresh(mapView: mapView, force: false)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        
        tileRefresh(mapView: mapView, force: true)
        
        if Chiriin.memCacheData.count > 20 {
            Chiriin.memCacheData = [:]
        }
    }
    
    private var lastOx = 0
    private var lastOy = 0
    private var lastSpan = Double(0)
    private var lastZoom = 9
    func tileRefresh(mapView: MKMapView, force: Bool) {
        guard let mapView = mapView as? MapView else { return }
        
        let zoom = lastZoom
        
        let (ox,oy) = Chiriin.getXY(zoom: zoom, coord: mapView.centerCoordinate)
        
        if lastOx == ox && lastOy == oy && lastSpan == mapView.region.span.longitudeDelta {
            DispatchQueue.main.async {
                self.tileRefresh(mapView: mapView, centerHeight: -1, noUpdate: true)
            }
            return
        }
        lastOx = ox
        lastOy = oy
        lastSpan = mapView.region.span.longitudeDelta
        
        // 中心部の標高を表示
        mapView.mapInfoView.heightLabel.text = ""
        Chiriin.getHeight(zoom: zoom, coord: mapView.centerCoordinate, callback: { _, _, _, centerHeight, _, _ in
            if centerHeight == nil {
                mapView.mapInfoView.heightLabel.text = "- m"
            } else {
                mapView.mapInfoView.heightLabel.text = "\(centerHeight!)m"
            }
            
            DispatchQueue.main.async {
                self.tileRefresh(mapView: mapView, centerHeight: centerHeight ?? 0, noUpdate: false)
            }
        })
    }
    
    private func tileRefresh(mapView: MapView, centerHeight: Double, noUpdate: Bool) {
        let topLeft = CGPoint(x: 0, y: 0)
        let topLeftCoord = mapView.convert(topLeft, toCoordinateFrom: mapView)
        let bottomRight = CGPoint(x: mapView.frame.width, y: mapView.frame.height)
        let bottomRightCoord = mapView.convert(bottomRight, toCoordinateFrom: mapView)
        
        var delta = mapView.region.span.longitudeDelta
        if UIScreen.main.bounds.width > 500 {
            delta *= 0.5
        }
        var zoom = 6
        if delta < 0.03 {
            zoom = 12
        } else if delta < 0.06 {
            zoom = 11
        } else if delta < 0.12 {
            zoom = 10
        } else if delta < 0.24 {
            zoom = 9
        } else if delta < 0.48 {
            zoom = 8
        } else if delta < 1 {
            zoom = 7
        }
        lastZoom = zoom
        
        
        let tileMapPerScreenWidth = (Double(bottomRightCoord.longitude - topLeftCoord.longitude) ) / 360 * pow(2, Double(zoom))
        let tileLayerSize = (mapView.frame.width / CGFloat(tileMapPerScreenWidth * 256))
        mapView.tileLayersView.sizeChange(tileSize: tileLayerSize)
        
        let (x1, y1) = getTileXY(zoom: zoom, coord: topLeftCoord)
        let (x2, y2) = getTileXY(zoom: zoom, coord: bottomRightCoord)
        
        if !noUpdate {
            var y = y1
            var iy: Int = 0
            while y < y2 {
                var url = URL(string: "https://cyberjapandata.gsi.go.jp/xyz/dem_png/\(zoom)/\(Int(x1))/\(Int(y)).png")!
                var memData = Chiriin.memCacheData[url]
                var x = x1
                var ix: Int = 0
                while x < x2 {
                    // タイル画像をダウンロード
                    if Int(x) - Int(x - Double(1) / 256) != 0 {
                        url = URL(string: "https://cyberjapandata.gsi.go.jp/xyz/dem_png/\(zoom)/\(Int(x))/\(Int(y)).png")!
                        memData = Chiriin.memCacheData[url]
                    }
                    let rx = (x - floor(x)) * 256
                    let ry = (y - floor(y)) * 256
                    // メモリ上にキャッシュがあれば使う
                    if let memData = memData {
                        let xx = Int(rx)
                        let yy = Int(ry)
                        let height = Chiriin.getPngHeight(pixelArray: memData, x: xx, y: yy)
                        var upHeight = height
                        if ry - 1 < 0 {
                            url = URL(string: "https://cyberjapandata.gsi.go.jp/xyz/dem_png/\(zoom)/\(Int(x))/\(Int(y - 1)).png")!
                            if let memData2 = Chiriin.memCacheData[url] {
                                upHeight = Chiriin.getPngHeight(pixelArray: memData2, x: xx, y: yy - 1 + 256)
                            }
                        } else {
                            upHeight = Chiriin.getPngHeight(pixelArray: memData, x: xx, y: yy - 1)
                        }
                        var leftHeight = height
                        if rx - 1 < 0 {
                            url = URL(string: "https://cyberjapandata.gsi.go.jp/xyz/dem_png/\(zoom)/\(Int(x - 1))/\(Int(y)).png")!
                            if let memData2 = Chiriin.memCacheData[url] {
                                leftHeight = Chiriin.getPngHeight(pixelArray: memData2, x: xx - 1 + 256, y: yy)
                            }
                        } else {
                            leftHeight = Chiriin.getPngHeight(pixelArray: memData, x: xx - 1, y: yy)
                        }
                        tileRefreshCallback(ix: ix, iy: iy, centerHeight: centerHeight, origHeight: height, upHeight: upHeight, leftHeight: leftHeight)
                    }
                    else {
                        Chiriin.getHeight(url: url, rx: rx, ry: ry, ix: ix, iy: iy, centerHeight: centerHeight, callback: self.tileRefreshCallback)
                    }
                    x += Double(1) / 256
                    ix += 1
                }
                y += Double(1) / 256
                iy += 1
            }
        }
        
        DispatchQueue.main.async {
            let tileSize: CGFloat = mapView.tileLayersView.lastTileSize
            let xOffset = CGFloat(x1 * 256 - floor(x1 * 256))
            let yOffset = CGFloat(y1 * 256 - floor(y1 * 256))
            mapView.tileLayersView.frame = CGRect(x: xOffset * -1 * tileSize,
                                                  y: yOffset * -1 * tileSize,
                                                  width: mapView.frame.width + tileSize,
                                                  height: mapView.frame.height + tileSize)
            
            mapView.tileLayersView.topLeftCoord = topLeftCoord
            
            mapView.tileLayersView.setNeedsDisplay()
        }
    }
    
    func tileRefreshCallback(ix: Int, iy: Int, centerHeight: Double, origHeight: Double?, upHeight: Double?, leftHeight: Double?) {
        let height = origHeight ?? 0
        guard let mapView = MapView.instance else { return }
        
        let k = pow(1.5, Double(lastZoom)) / 58
        
        var r: CGFloat = 0
        var g: CGFloat = 1
        var b: CGFloat = 0
        var alpha: CGFloat = 0.3
        
        let diff = k * (height - centerHeight)
        
        if origHeight == nil {
            alpha = 0
        }
        else if diff > 30 {
            r = 1
            g = CGFloat(min(1.0, (diff - 30) / 300))
            b = g
        } else if diff > 10 {
            r = 1
            g = CGFloat( -diff ) / 20 + 1.5
        } else if diff > 0 {
            r = CGFloat( diff ) / 10
            g = 1
        } else if diff > -10 {
            g = 1
            b = CGFloat( -diff ) / 10
        } else if diff > -30 {
            g = CGFloat( diff ) / 40 + 1.25
            r = 1 - g
            b = 1
        } else {
            r = 0.5
            g = 0.5
            b = CGFloat(max(0.0, 1 - (-diff - 30) / 300))
        }
        
        if upHeight != nil && leftHeight != nil {
            var cdiff = CGFloat(k) * CGFloat(abs(leftHeight! - height) + abs(upHeight! - height))
            if cdiff > 5 {
                cdiff = 5 + min(80, cdiff - 5) / 15
            }
            if cdiff > 1 {
                if diff < -30 {
                    r = r * (10 - cdiff) / 10
                    g = g * (10 - cdiff) / 10
                    b = b * (10 - cdiff) / 10
                } else {
                    r = r * (15 - cdiff) / 15
                    g = g * (15 - cdiff) / 15
                    b = b * (15 - cdiff) / 15
                }
            }
        }
        
        objc_sync_enter(mapView.tileLayersView)
        
        if iy < mapView.tileLayersView.tileColors.count {
            if ix < mapView.tileLayersView.tileColors[0].count {
                mapView.tileLayersView.tileColors[iy][ix] = UIColor(red: r, green: g, blue: b, alpha: alpha)
            }
        }
        
        objc_sync_exit(mapView.tileLayersView)
    }
}
