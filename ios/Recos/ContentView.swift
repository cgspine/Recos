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
                NavigationLink(destination: EvalView(bundleName: "differentHeight", moduleName: "HelloWorld")) {
                    Text("ListView: have different style, can click")
                }
                NavigationLink(destination: EvalView(bundleName: "hello", moduleName: "HelloWorld")) {
                    Text("ListView: show a lot of data, can click")
                }
                NavigationLink(destination: EvalView(bundleName: "image", moduleName: "HelloWorld")) {
                    Text("Image: load local image / internet image")
                }
                NavigationLink(destination: EvalView(bundleName: "css_style", moduleName: "HelloWorld")) {
                    Text("CSS: show all css style")
                }
                NavigationLink(destination: RecosContentView()) {
                    Text("Flex Box")
                }
                NavigationLink(destination: EvalView(bundleName: "waterfall", moduleName: "Waterfall")) {
                    Text("Water Fall")
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Recos"), displayMode: .large)
        }
    }
    
}
