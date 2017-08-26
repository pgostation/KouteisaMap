//
//  ViewController.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        DispatchQueue.main.async {
            let vc = MapViewController()
            self.present(vc, animated: false, completion: nil)
        }
    }
}

