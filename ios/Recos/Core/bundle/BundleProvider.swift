//
//  BundleProvider.swift
//  Example
//
//  Created by tigerAndBull on 2021/6/12.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation

public protocol BundleProvider {
    func prepare() -> String
    func getBundlePath(bundleName: String) -> String
    func getBundleContent(bundleName: String) -> String
}
