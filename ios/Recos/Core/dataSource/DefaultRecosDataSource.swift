//
//  DefaultRecosDataSource.swift
//  Example
//
//  Created by tigerAndBull on 2021/6/12.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation
import SwiftyJSON

class DummyRecosDataSource: RecosDataSource {
    func parse(bundleName: String) {
    }
    
    func getModel(moduleName: String) -> FunctionDecl? {
        return nil
    }
    
    func getExitModule(moduleName: String) -> FunctionDecl? {
        return nil
    }
    
    var scope: JsScope?
    init(scope: JsScope?) {
        self.scope = scope
    }
}

class DefaultRecosDataSource: RecosDataSource {
    private var waitingChannel: NSMutableDictionary? = nil
    private var loadedBundle: [String]?
    private var bundleProvider: BundleProvider
    private var dummyJsEvaluator: JsEvaluator?
    private var globalStackFrame: JsStackFrame?
    var rootScope: JsScope?
    
    init() {
        self.waitingChannel = NSMutableDictionary()
        self.loadedBundle = []
        self.bundleProvider = AssetBundleProvider.init()
        self.globalStackFrame = JsStackFrame(parentScope: nil)
        self.dummyJsEvaluator = JsEvaluator(dataSource: DummyRecosDataSource(scope: globalStackFrame?.scope))
        self.rootScope = self.globalStackFrame?.scope
    }
    
    func parse(bundleName: String) {
        let text: String = bundleProvider.getBundleContent(bundleName: bundleName)
        
        if let data = text.data(using: .utf8) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let json = JSON(jsonObject)
                var nodes = [Node]()
                for (_, item):(String, JSON) in json {
                    let node = Node(json: item)
                    if node != nil {
                        nodes.append(node!)
                    }
                }
                for node in nodes {
                    self.dummyJsEvaluator?.runNode(frame: globalStackFrame!, scope: rootScope!, node: node)
                }
            } catch {
                print(String(format: "Recos can not parse the bundle named %@", bundleName))
            }
        }
    }
    
    func getModel(moduleName: String) -> FunctionDecl? {
        let function = rootScope?.getFunction(name: moduleName)
        if function != nil {
            return function
        }
        return nil
    }
    
    func getExitModule(moduleName: String) -> FunctionDecl? {
        return rootScope?.getFunction(name: moduleName)
    }
}
