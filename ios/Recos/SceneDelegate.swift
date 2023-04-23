//
//  SceneDelegate.swift
//  Recos
//
//  Created by wenhuan on 2021/7/5.
//

import UIKit
import SwiftUI
import JavaScriptCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView())
            self.window = window
            
//            let context = JSContext()
//            print("JS engine", Date().timeIntervalSince1970)
//            let value = context?.evaluateScript("let test1 = 100 \n for (let i = 0; i < 200000; i++) {  test1 += 10 }")?.toInt32()
//            print(value)
//            print("JS engine", Date().timeIntervalSince1970)

//            print("测试", Date().timeIntervalSince1970)
//            let model = ["name": "111", "invalidTimeStamp": 10000, "pageName": "home_page"] as [String : Any]
//            let mallType = getMallTypeByPageName(pageName: model["pageName"] as! String)
//            let mallName = getNameByPageName(pageName: model["pageName"] as! String)
//            let timeStamp = parseTimeStamp(invalidTimeStamp: model["invalidTimeStamp"] as! Int)
//            report(mallType: mallType, mallName: mallName)
//            print("测试", Date().timeIntervalSince1970)
//            print(timeStamp)
            
            window.makeKeyAndVisible()
        }
    }
    
    func report(mallType: Int, mallName: String) {
        print("打点上报")
        print(mallName)
        print(mallType)
    }
    
    func getNameByPageName(pageName: String) -> String {
        if (pageName == "home_page") {
            return "买首"
        }
        return "商城"
    }
    
    func getMallTypeByPageName(pageName: String) -> Int {
        if (pageName == "home_page") {
            return 0
        }
        return 1
    }
    
    func parseTimeStamp(invalidTimeStamp: Int) -> String {
        if (invalidTimeStamp <= 0) {
            return ""
        }

        let hours = round(Double(invalidTimeStamp / 3600000));
        var hoursPart = hours * 3600000

        let mins = round(((Double(invalidTimeStamp) - hoursPart) / 60000));
        var minsPart = mins * 60000

        let secs = round((Double(invalidTimeStamp) - hoursPart - minsPart) / 1000);

        var hoursText = String(hours)
        if (hours < 10) {
            hoursText = "0" + hoursText
        }

        var minsText = String(mins)
        if (mins < 10) {
            minsText = "0" + minsText
        }

        var secsText = String(secs)
        if (secs < 10) {
            secsText = "0" + secsText;
        }

        if (hoursText.count > 0) {
            return hoursText + "时" + minsText + "分" + secsText + "秒";
        }

        if (minsText.count > 0) {
            return minsText + "分" + secsText + "秒"
        }

        return secsText + "秒"
    }
    
    func viewTest() {
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}
