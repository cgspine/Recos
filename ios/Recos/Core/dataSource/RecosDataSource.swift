//
//  RecosDataSource.swift
//  Example
//
//  Created by tigerAndBull on 2021/6/8.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation

public protocol RecosDataSource {
    func parse(bundleName: String) -> Void
    func getModel(moduleName: String) -> FunctionDecl?
    func getExitModule(moduleName: String) -> FunctionDecl?
}
