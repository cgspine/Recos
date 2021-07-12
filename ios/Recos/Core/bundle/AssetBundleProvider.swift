//
//  AssetBundleProvider.swift
//  Example
//
//  Created by tigerAndBull on 2021/6/12.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation

let TAG = "AssetBundleProvider"

class AssetBundleProvider: BundleProvider {
    
    var bundleSourceDirPath: String? = nil
    var drawableSourceDirPath: String? = nil
    var storageDir: String? = nil
    var version: String? = nil
    var coreBundle: String!
    var preloadBundles: [String]? = nil
    var checkAndDeleteOldBundles: Bool = true
    var supportedDrawableSuffixList: [String]? = [".png", ".jpg"]
    
    init() {
        
    }
    
    private func isBundleCopied(bundle: String) -> Bool {
        return FileManager.default.fileExists(atPath: bundle)
    }
    
    private func copyDrawables() {}
    
    func prepare() -> String {
        return ""
    }
    
    func getBundlePath(bundleName: String) -> String {
        return ""
    }

    func getBundleContent(bundleName: String) -> String {
        if let fileURL = Bundle.main.url(forResource: bundleName, withExtension: "bundle") {
            if let fileContents = try? String(contentsOf: fileURL) {
                print("AssetBundleProvider" + fileContents)
                return fileContents
            }
        }
        return ""
    }
    
    
}
