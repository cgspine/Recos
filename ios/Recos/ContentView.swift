//
//  ContentView.swift
//  Recos
//
//  Created by wenhuan on 2021/7/12.
//

import Foundation
import SwiftUI

/*
 <VStack
    name=''
    width=''
    data='@data:xx:xx:xx'
 >
    
 </VStack>
 */

struct ContentView : View {
    
    var dataSource = DefaultRecosDataSource()
    
    init() {
        ParseManager.shared.parse(bundleName: "viewTest")
    }
    
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
                NavigationLink(destination: TestLazyStack()) {
                    Text("Test")
                }
                NavigationLink(destination: NavigationLazyView(TestView().onAppear(perform: testLog))) {
                    Text("tk view Test")
                }
                NavigationLink(destination: TestLogicView().onAppear(perform: testLog)) {
                    Text("tk logic Test")
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Recos"), displayMode: .large)
        }
    }
    
    func testLog() {
        print("时间", Date().timeIntervalSince1970)
        print("时间","=======")
    }
    
}

class ParseManager {
    
    static let shared = ParseManager()
    
    private init() {}
    
    var parseMap: [String : DefaultRecosDataSource] = [:]
    
    public func parse(bundleName: String) {
        let dataSource = DefaultRecosDataSource()
        dataSource.parse(bundleName: bundleName)
        self.parseMap[bundleName] = dataSource
    }
    
    public func getDataSouce(bundleName: String) -> DefaultRecosDataSource {
        return self.parseMap[bundleName] ?? DefaultRecosDataSource()
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct TestBigView : View {

    var body: some View {
        TestView()
        TestView()
        TestView()
        TestView()
        TestView()
        TestView()
        TestView()
        TestView()
        TestView()
    }
}

struct TestView : View {
    
    var body: some View {
        EvalView(dataSource: ParseManager.shared.getDataSouce(bundleName: "viewTest"), moduleName: "Test", logEnable: true)
        EvalView(dataSource: ParseManager.shared.getDataSouce(bundleName: "viewTest"), moduleName: "Test")
        EvalView(dataSource: ParseManager.shared.getDataSouce(bundleName: "viewTest"), moduleName: "Test")
        EvalView(dataSource: ParseManager.shared.getDataSouce(bundleName: "viewTest"), moduleName: "Test")
        EvalView(dataSource: ParseManager.shared.getDataSouce(bundleName: "viewTest"), moduleName: "Test")
        EvalView(dataSource: ParseManager.shared.getDataSouce(bundleName: "viewTest"), moduleName: "Test")
        EvalView(dataSource: ParseManager.shared.getDataSouce(bundleName: "viewTest"), moduleName: "Test")
    }
}

struct TestLogicView : View {
    
    let myDictionary = ["name": "测试名称", "invalidTimeStamp": 100000000, "pageName": "home_page"] as [String : Any]
    
    var body: some View {
        EvalView(bundleName: "testLogic", moduleName: "Test", entryData: myDictionary)
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
                 
