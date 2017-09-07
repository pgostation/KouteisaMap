//
//  Settings.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import Foundation
import MapKit

class Settings {
    private static let userDefaults = UserDefaults.standard
    
    // 地図の種類設定
    static var mapType: String {
        get {
            return userDefaults.string(forKey: "mapType") ?? "標準"
        }
        set(str) {
            userDefaults.set(str, forKey: "mapType")
            
            MapViewController.instance?.setMapType(str: str)
        }
    }
    
    // 表示モード設定
    static var sensitiveMode: String {
        get {
            return userDefaults.string(forKey: "sensitiveMode") ?? "標準"
        }
        set(str) {
            userDefaults.set(str, forKey: "sensitiveMode")
            
            MapView.instance?.refresh()
        }
    }
    
    // 地名検索
    static func searchAction(viewController: UITableViewController) {
        ViewUtil.textInput(msg: "地名を入力してください", defaultText: "", okName: "検索", callback: { text in
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = text
            
            MKLocalSearch(request: request).start(completionHandler: {
                (response: MKLocalSearchResponse?, error: Error?) in
                
                if let error = error {
                    print("searchAction(): \(error.localizedDescription)")
                    return
                }
                
                if response?.mapItems.count == 0 {
                    ViewUtil.alert(msg: "見つかりませんでした")
                    return
                }
                
                if let item = response?.mapItems.first {
                    viewController.view.alpha = 0.5
                    
                    MapView.instance?.setCenter(item.placemark.coordinate, animated: false)
                    
                    DispatchQueue.main.async {
                        viewController.dismiss(animated: true, completion: nil)
                    }
                }
            })
        })
    }
    
    // 共有パネルを表示
    static func shareApp(viewController: UITableViewController) {
        let shareText = "色で高低差が分かる iPhoneアプリ「高低差色地図」"
        let shareWebsite = URL(string: "https://itunes.apple.com/jp/app/高低差色地図/id1275625163?l=ja&mt=8")!
        
        let activityItems: [Any] = [shareText, shareWebsite]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivityType.addToReadingList,
            UIActivityType.saveToCameraRoll,
            UIActivityType.print
        ]
        activityViewController.excludedActivityTypes = excludedActivityTypes
        
        viewController.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.async {
            MapViewController.instance?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // Peteアプリページへ移動
    static func peteLink(viewController: UIViewController, url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        DispatchQueue.main.async {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}
