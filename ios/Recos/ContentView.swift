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
                    Text("ListView: have different style, can click")
                }
                NavigationLink(destination: EvalView(bundleName: "hello")) {
                    Text("ListView: show a lot of data, can click")
                }
                NavigationLink(destination: EvalView(bundleName: "image")) {
                    Text("Image: load local image / internet image")
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Recos"), displayMode: .large)
        }
    }
    
}
