//
//  SceneDelegate.swift
//  Recos
//
//  Created by wenhuan on 2021/7/5.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let defaultRecosDataSource = DefaultRecosDataSource.init()
            defaultRecosDataSource.parse(bundleName: "hello.bundle")
            guard let function = defaultRecosDataSource.getModel(modleName: "HelloWorld") else { return }
            let jsEvaluator = JsEvaluator(dataSource: defaultRecosDataSource)
            let view = EvalView(functionDecl: function, parentScope: nil, args: nil, evaluator: jsEvaluator)
            window.rootViewController = UIHostingController(rootView: view)
            self.window = window
            window.makeKeyAndVisible()
        }
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
