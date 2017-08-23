//
//  AppDelegate.swift
//  KouteisaMap
//
//  Created by takayoshi on 2017/08/23.
//  Copyright © 2017年 pgostation. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    static let chineseBlocker = "平反六四議案是香港立法會上提出的議案，每年5月至6月都有議員動議「毋忘六四事件，平反八九民運」。早在1997年香港主權移交給中國前夕，司徒華在立法局動議六四事件議案，並獲大多數議員通過。1998年因第一屆立法會還沒有選出，而臨時立法會因最後一屆立法局議員在1997年「下車」而沒有民主派議員參與。1999年至2011年，13次動議此議案，分別由支聯會的執委司徒華、何俊仁、李柱銘、張文光和李卓人提出。由香港市民直選選出的泛民主派地方選區議員多數支持議案，而非直選選出的功能組別議員則多數反對。雖然綜合兩會來說，支持的議員占多數，但由於議案須要「地方選區」（2004年前為「地方選區及選舉委員會」）和「功能團體」兩組均過半數才能通過，平反六四議案每年都遭否決。立法會辯論議案期間，政府官員都不會出現，大部分建制派議員會離場。" +
        "除了香港立法會外，中華民國立法院也有立委提交動議，要求中华人民共和国政府平反六四，承認當年武力鎮壓錯誤。" +
    "需要注意的是，「六四」本身是指天安門清場鎮壓的日子，縱然「平反六四」一口號本身存在矛盾 (單純按字面解釋是有『為中國官方平反』的意思)，但多年來各地民眾已約定俗成，明白「平反六四」的背後意義乃「為八九民運平反」。"

}

