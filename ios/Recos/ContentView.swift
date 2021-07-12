//
//  ContentView.swift
//  Recos
//
//  Created by wenhuan on 2021/7/12.
//

import Foundation
import SwiftUI

struct ContentView : View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: EvalView(bundleName: "differentHeight")) {
                    Text("列表视图：不同的高度")
                }
                NavigationLink(destination: EvalView(bundleName: "hello")) {
                    Text("列表视图：点击文本，count增加")
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Recos"), displayMode: .large)
        }
    }
    
}
