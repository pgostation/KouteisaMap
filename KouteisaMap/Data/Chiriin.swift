//
//  Chiriin.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit
import CoreLocation
import CoreGraphics

class Chiriin {
    // 高さを返す
    static func getHeight(zoom: Int, coord: CLLocationCoordinate2D, callback: @escaping (Int, Int, Double, Double?, Double?, Double?)->Void) {
        // タイルのx,yを求める
        let n: Double = pow(2, Double(zoom))
        let xTile = (Double(coord.longitude) + 180) / 360 * n
        let lat_rad = Double(coord.latitude) * Double.pi / 180
        let yTile = ( 1 - ( log(tan(lat_rad) + 1 / (cos(lat_rad))) / Double.pi ) ) * n / 2
        
        // 余り分を求める
        let rx = (xTile - floor(xTile)) * 256.0
        let ry = (yTile - floor(yTile)) * 256.0
        
        let url = URL(string: "https://cyberjapandata.gsi.go.jp/xyz/dem_png/\(zoom)/\(Int(xTile))/\(Int(yTile)).png")!
        
        getHeight(url: url, rx: rx, ry: ry, ix: 0, iy: 0, centerHeight: 0, callback: callback)
    }
    
    static func getXY(zoom: Int, coord: CLLocationCoordinate2D) -> (Int, Int) {
        let n: Double = pow(2, Double(zoom))
        let xTile = (Double(coord.longitude) + 180) / 360 * n
        let lat_rad = Double(coord.latitude) * Double.pi / 180
        let yTile = ( 1 - ( log(tan(lat_rad) + 1 / (cos(lat_rad))) / Double.pi ) ) * n / 2
        
        return (Int(xTile * 256), Int(yTile * 256))
    }
    
    static func coordFrom(zoom: Int, x: Int, y: Int) -> CLLocationCoordinate2D {
        let n: Double = pow(2, Double(zoom))
        
        let xTile = (Double(x) + 0.5) / 256
        let longitude = xTile / n * 360 - 180
        
        let yTile = (Double(y) + 0.5) / 256
        let lat_rad = atan(sinh(Double.pi * (1 - 2 * yTile / n)))
        let latitude = lat_rad * 180.0 / Double.pi
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func getHeight(url: URL, rx: Double, ry: Double, ix: Int, iy: Int, centerHeight: Double, callback: @escaping (Int, Int, Double, Double?, Double?, Double?)->Void) {
        download(url: url, callback: { pixelArray in
            if let pixelArray = pixelArray {
                // PNG画像から標高を取得
                let height = getPngHeight(pixelArray: pixelArray, x: Int(rx), y: Int(ry))
                callback(ix, iy, centerHeight, height, nil, nil)
            } else {
                callback(ix, iy, centerHeight, nil, nil, nil)
            }
        })
    }
    
    static var memCacheData: [URL:[UInt8]] = [:]
    private static var dowloadList: [URL: [([UInt8]?)->Void]] = [:]
    private static let queue = DispatchQueue(label: "chiriin")
    
    // タイル画像をダウンロード
    static func download(url: URL, callback: @escaping ([UInt8]?)->Void) {
        // キャッシュがあればそちらを使う
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let cacheFilename = url.path.replacingOccurrences(of: "/", with: "|")
        let savePath = documentPath + "/maps/" + cacheFilename
        let saveUrl = URL(fileURLWithPath: savePath)
        if FileManager().fileExists(atPath: savePath) {
            // ファイルの参照日を更新
            let attrs = [FileAttributeKey.modificationDate: Date()]
            do {
                try FileManager().setAttributes(attrs, ofItemAtPath: saveUrl.path)
            } catch {
            }
            
            // キャッシュデータを返す
            do {
                let data = try Data(contentsOf: saveUrl)
                guard let imageRef = UIImage(data: data)?.cgImage else {
                    callback(nil)
                    return
                }
                let pixelArray = getByteArrayFromImage(imageRef: imageRef)
                memCacheData[url] = pixelArray
                callback(pixelArray)
                return
            } catch {
                print("load cache file failure.")
            }
        }
        
        if var list = dowloadList[url] {
            list.append(callback)
            dowloadList[url] = list
            return
        } else {
            dowloadList[url] = [callback]
        }
        
        queue.async {
            // ダウンロード
            var request: URLRequest = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request, completionHandler: { (data: Data?, resp: URLResponse?, error: Error?) in
                if let error = error {
                    print("Chiriin.download(): \(error.localizedDescription)")
                }
                
                if !FileManager().fileExists(atPath: documentPath + "/maps/") {
                    // mapsディレクトリを作成
                    do {
                        try FileManager().createDirectory(atPath: documentPath + "/maps/", withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("create 'maps' directory failure.")
                    }
                    // バックアップ対象から除外
                    do {
                        var filePath = URL(fileURLWithPath: documentPath + "/maps/")
                        var resourceValues = URLResourceValues()
                        resourceValues.isExcludedFromBackup = true
                        try filePath.setResourceValues(resourceValues)
                    } catch _{
                        print("isExcludedFromBackupKey Failed")
                    }
                }
                
                do {
                    try data?.write(to: saveUrl)
                } catch {
                    print("save to file failure.")
                }
                
                if data != nil {
                    // キャッシュ枚数が多すぎる場合は削除する
                    let fileManager = FileManager()
                    do {
                        let list = try fileManager.contentsOfDirectory(atPath: documentPath + "/maps/")
                        if list.count >= 100 {
                            // 一番参照日が古いものを削除する
                            var oldestDate = Date()
                            var oldestPath: String?
                            for path in list {
                                let attr = try fileManager.attributesOfItem(atPath: path) as NSDictionary
                                if let modifyDate = attr.fileModificationDate() {
                                    if oldestDate > modifyDate {
                                        oldestDate = modifyDate
                                        oldestPath = path
                                    }
                                }
                            }
                            if let oldestPath = oldestPath {
                                try fileManager.removeItem(at: URL(fileURLWithPath: oldestPath))
                            }
                        }
                    } catch {
                        print("remove cache file failure.")
                    }
                }
                
                DispatchQueue.main.async {
                    let imageRef = data != nil ? UIImage(data: data!)?.cgImage : nil
                    let pixelArray = imageRef != nil ? getByteArrayFromImage(imageRef: imageRef!) : nil
                    
                    if let list = dowloadList[url] {
                        for clbk in list {
                            clbk(pixelArray)
                        }
                        dowloadList.removeValue(forKey: url)
                    }
                }
                
                session.finishTasksAndInvalidate()
            })
            task.resume()
        }
    }
    
    // PNG画像から標高を取得
    static func getPngHeight(pixelArray: [UInt8], x: Int, y: Int) -> Double? {
        if pixelArray.count < 256 * 256 * 4 { return nil }
        let pixelRed = Double(pixelArray[4 * (256 * y + x) + 0])
        let pixelGreen = Double(pixelArray[4 * (256 * y + x) + 1])
        let pixelBlue = Double(pixelArray[4 * (256 * y + x) + 2])
        
        let height = Double( pixelRed * 65536 + pixelGreen * 256 + pixelBlue )
        if height < 8388608 {
            return height / 100
        }
        else if height == 8388608 {
            return nil
        }
        return (height - 16777216) / 100
    }
    
    // ピクセル配列を取得
    static func getByteArrayFromImage(imageRef: CGImage) -> [UInt8]? {
        guard let data = imageRef.dataProvider?.data else { return nil }
        let length = CFDataGetLength(data)
        var rawData = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        
        return rawData
    }
    
    // 前の処理が残っているかどうか
    private static var mainThreadIsBusy = false
    static func isBusy() -> Bool {
        if mainThreadIsBusy { return true }
        return dowloadList.count > 0
    }
}
