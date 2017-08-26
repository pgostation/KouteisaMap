//
//  ViewUtil.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/24.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

class ViewUtil {
    // 一番前面のViewControllerを取得する
    static func getFrountViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return getFrountViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return getFrountViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return getFrountViewController(controller: presented)
        }
        return controller
    }
    
    // アラートダイアログを表示する
    static func alert(msg: String) {
        guard let frontViewController = getFrountViewController() else { return }
        if frontViewController as? UIAlertController != nil {
            // 後から表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                ViewUtil.alert(msg: msg)
            })
        } else {
            print("alert(): \(msg)")
            
            let alert = UIAlertController(title:"", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                _ in
            })
            
            alert.addAction(action)
            
            // すぐに表示
            frontViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // テキスト入力欄付きダイアログを表示する
    static func textInput(msg: String, defaultText: String?, okName: String = "OK", callback: @escaping (String?)->Void) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        let saveAction = UIAlertAction(title: okName, style: .default) { (action:UIAlertAction!) -> Void in
            
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
            callback(textField.text)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
            callback(nil)
        }
        
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.text = defaultText
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        getFrountViewController()?.present(alert, animated: true, completion: nil)
    }
    
    // アラートダイアログが閉じた後に処理を実行する
    static func afterAlert(callback: @escaping (Void)->Void) {
        guard let frontViewController = getFrountViewController() else { return }
        if frontViewController as? UIAlertController != nil {
            // 後から表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                ViewUtil.afterAlert(callback: callback)
            })
        } else {
            // すぐに表示
            callback()
        }
    }
}
