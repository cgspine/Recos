//
//  CustomFlexBoxView.swift
//  Recos
//
//  Created by wenhuan on 2021/8/10.
//

import Foundation
import SwiftUI

struct RecosContentView: View {
    @State var data: [String] = [
        "113", "2", "2342343", "234", "234234234234324", "3",
        "45345435345345", "545", "34", "4", "345345345", "45345", "5", "5", "2342343", "234", "234234234234324", "3",
        "45345435345345", "545", "34", "4", "345345345", "45345", "5", "23423423423442343242343232423423423423432423"]
    
    var body: some View {
        ScrollView {
            CustomFlexBoxView(alignment: .topLeading, spacing: 10, items: data, content: self.getAnyView(index:))
        }
        .padding()
    }
    
    func getAnyView(index: Int) -> AnyView {
        let text = String(self.data[index])
        return AnyView(TestText(text: text))
    }
}

struct TestText : View {
    let text: String
    @State private var color: Bool = false
    
    var body: some View {
        VStack {
            EvalImage(url: "", placeholder: "placeholder", width: 100, height: 100)
            Text(self.text)
                .lineLimit(1)
                .background(self.color ? Color.orange : Color.gray)
                .foregroundColor(self.color ? Color.green : Color.black)
                .onTapGesture {
                    self.color.toggle()
                }
            Text(self.text)
            Text(self.text)
            Text(self.text)
        }
    }
}


struct CustomFlexBoxView<Item, Content> : View where Item: Hashable, Content: View {
    let alignment: Alignment
    let spacing: CGFloat
    let items: [Item]
    let content: (Int) -> Content
    var thisWidthIsLoad = false
    var oldWidth = CGFloat.zero
    
    @State private var sizeBody: CGSize? = nil
    @State private var widthItems: [Item: CGFloat] = [:]
    
    init(alignment: Alignment = .center, spacing: CGFloat = 0, items: [Item], @ViewBuilder content: @escaping (Int) -> Content) {
        self.spacing = spacing
        self.alignment = alignment
        self.items = items
        self.content = content
    }
    
    var body: some View {
        self.contentView
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity, alignment: self.alignment)
            .background(
                GeometryReader { (geo) in
                    Color.clear.onAppear {
                        self.sizeBody = geo.frame(in: .global).size
                    }
                }
            ).padding(10)
    }
    
    private var contentView: some View {
        VStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
            ForEach(self.rowsIndices, id: \.self) { (row) in
                self.createRow(indices: row)
            }
        }
    }
    
    private func createRow(indices: [Int]) -> some View {
        HStack(alignment: self.alignment.vertical, spacing: self.spacing) {
            ForEach(indices, id: \.self) { (index) in
                Group {
                    self.content(index)
                }
                .background(
                    GeometryReader { (geo) in
                        Color.clear.onAppear {
                            self.widthItems[self.items[index]] = geo.frame(in: .global).size.width
                        }
                    }
                )
            }
        }
    }
    
    private var rowsIndices: [[Int]] {
        print("rowsIndices")
        guard let widthBody = self.sizeBody?.width else {
            print(self.items.indices.map { [ $0 ] })
            return self.items.indices.map { [ $0 ] }
        }
        
        var rowWidth: CGFloat = 0
        var rowItems: [Int] = []
        var rows: [[Int]] = []
        
        for index in 0 ..< items.count {
            if let widthItem = self.widthItems[self.items[index]] {
                let rowWidthNext = rowWidth + widthItem + (rowItems.isEmpty ? 0 : self.spacing)
                if rowWidthNext <= widthBody {
                    rowItems.append(index)
                    rowWidth = rowWidthNext
                } else {
                    if rowItems.isEmpty == false {
                        rows.append(rowItems)
                        rowWidth = 0
                        rowItems = []
                    }
                    rowWidth = widthItem
                    rowItems = [ index ]
                }
            } else {
                if rowItems.isEmpty == false {
                    rows.append(rowItems)
                    rowWidth = 0
                    rowItems = []
                }
                rows.append([ index ])
            }
        }
        if rowItems.isEmpty == false {
            rows.append(rowItems)
            rowWidth = 0
            rowItems = []
        }
        print(rows)
        return rows
    }
}

struct ItemView: View {
    let value: Int
    var body: some View {
        Text("Item\(value)")
            .padding()
            .background(Color.blue)
            .lineLimit(1)
    }
}

struct JustifiedContainer<V: View>: View {
    let views: [V]
    
    init(_ views: V...) {
        self.views = views
    }

    init(_ views: [V]) {
        self.views = views
    }
    
    var body: some View {
        HStack {
            ForEach(views.indices, id: \.self) { i in
                views[i]
//                if views.count > 1 && i < views.count - 1 {
//                    Spacer()
//                }
            }
        }
    }
}

struct Demo_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            JustifiedContainer(
                    ItemView(value: 1329382),
                    ItemView(value: 2320392093),
                    ItemView(value: 332390232323)
            )
            JustifiedContainer([
                    ItemView(value: 1323232),
                    ItemView(value: 23232323232),
                    ItemView(value: 332),
                    ItemView(value: 43232)
            ])
        }
    }
}
