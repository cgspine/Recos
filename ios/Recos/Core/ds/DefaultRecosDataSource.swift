//
//  DefaultRecosDataSource.swift
//  Example
//
//  Created by tigerAndBull on 2021/6/12.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation
import SwiftyJSON

class DefaultRecosDataSource: RecosDataSource {
    
    func getExitModule(modleName: String) -> FunctionDecl? {
        return self.functionList[modleName]
    }
    
    private var functionList: Dictionary<String, FunctionDecl>
    private var waitingChannel: NSMutableDictionary? = nil
    private var loadedBundle: [String]?
    
    private var bundleProvider: BundleProvider
    
    init() {
        self.functionList = Dictionary()
        self.waitingChannel = NSMutableDictionary()
        self.loadedBundle = []
        self.bundleProvider = AssetBundleProvider.init()
    }
    
    func parse(bundleName: String) {
        
        let text: String = bundleProvider.getBundleContent(bundleName: bundleName)
        
        if let data = text.data(using: .utf8) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let json = JSON(jsonObject)
                var nodes = [Node]()
                for (_, item):(String, JSON) in json {
                    let node = Node(json: item)!
                    nodes.append(node)
                }
                for node in nodes {
                    if node.type == TYPE_DECL_FUNC {
                        let function = node.content as! FunctionDecl
                        functionList[function.name] = function
                    }
                }
            } catch {
                print("erroMsg")
            }
        }
    }
    
    func getModel(modleName: String) -> FunctionDecl? {
        let function = functionList[modleName]
        if (function != nil) {
            return function
        }
        return nil
    }
}
