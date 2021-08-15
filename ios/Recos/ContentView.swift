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
//                NavigationLink(destination: EvalView(bundleName: "hello", moduleName: "HelloWorld")) {
//                    Text("ListView: show a lot of data, can click")
//                }
//                NavigationLink(destination: EvalView(bundleName: "image", moduleName: "HelloWorld")) {
//                    Text("Image: load local image / internet image")
//                }
//                NavigationLink(destination: EvalView(bundleName: "css_style", moduleName: "HelloWorld")) {
//                    Text("CSS: show all css style")
//                }
//                NavigationLink(destination: RecosContentView()) {
//                    Text("Flex Box")
//                }
//                NavigationLink(destination: EvalView(bundleName: "waterfall", moduleName: "Waterfall")) {
//                    Text("Water Fall")
//                }
//                NavigationLink(destination: AlignmentGuidesToolContentView()) {
//                    Text("AlignmentGuides")
//                }
                NavigationLink(destination: EvalView(bundleName: "selectFriend", moduleName: "SelectFriendLoadView")) {
                    Text("Select Friend")
                }
//                NavigationLink(destination: VStack {
//                    JustifiedContainer(
//                            ItemView(value: 1329382),
//                            ItemView(value: 2320392093),
//                            ItemView(value: 332390232323)
//                    )
//                    JustifiedContainer([
//                            ItemView(value: 1323232),
//                            ItemView(value: 2323232323245633232),
//                            ItemView(value: 332),
//                            ItemView(value: 43232)
//                    ])
//                }) {
//                    Text("JustifiedContainer")
//                }
                NavigationLink(destination: TestLazyStack()) {
                    Text("Test")
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Recos"), displayMode: .large)
        }
    }
    
}

struct TestLazyModel {
    let title: String
    let index: Int
    let value: Float
    
    public func getText() -> String {
        var text:String = ""
        text.append(self.title)
        text.append("item ")
        text.append(String(self.index))
        text.append(" ")
        text.append(String(self.value))
        return text
    }
}

struct TestLazyStack : View {
    var data: [TestLazyModel] = []
    
    init() {
        for i in 0...20000 {
            var title: String = ""
            if i % 2 == 0 {
                title = "偶数: "
            } else {
                title = "奇数: "
            }
            let model = TestLazyModel(title: title, index: i, value: Float(0))
            self.data.append(model)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(0..<self.data.count) { index in
                    let model = self.data[index]
                    Text(model.getText()).foregroundColor(Color.red).padding(10)
                    EvalImage(url: "https://wehear-1258476243.file.myqcloud.com/hemera/cover/59d/7f2/t9_5b8a0600339149c4ea55001b0f.png", placeholder: "placeholder", width: 36, height: 36, borderRadius: 18)
                }
            }
        }
    }
}
