//
//  FlexBox.swift
//  Example
//
//  Created by tigerAndBull on 2021/6/12.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation
import SwiftUI

enum Display {
    case flex
    case inlineFlex
}

enum FlexDirection {
    case Row
//    case RowReverse
    case Column
//    case ColumnReverse
}

enum JustifyContent {
    case FlexStart
    case FlexEnd
    case Center
    case SpaceBetween
    case SpaceAround
}

enum AlignItems {
    case FlexStart
    case FlexEnd
    case Center
    case Baseline
    case Stretch
}

enum AlignContent {
    case FlexStart
    case FlexEnd
    case Center
    case SpaceBetween
    case SpaceAround
    case SpaceEvenly
    case Stretch
}

enum AlignSelf {
    case Auto
    case FlexStart
    case FlexEnd
    case Center
    case Baseline
    case Stretch
}

enum FlexWrap {
    case Wrap
//    case WrapReverse
    case NoWrap
}

struct FlexPreferenceValue: Equatable {
    let viewId: Int
    let rect: CGRect
}

struct FlexPreferenceKey: PreferenceKey {
    typealias Value = [FlexPreferenceValue]
    static var defaultValue: [FlexPreferenceValue] = []
    static func reduce(value: inout [FlexPreferenceValue], nextValue: () -> [FlexPreferenceValue]) {
        value.append(contentsOf: nextValue())
    }
}

struct RecosFlexBoxView<Item, Content> : View where Item: Hashable, Content: View {
    var alignment: Alignment
    let spacing: CGFloat
    var items: [Item]
    let content: (Int) -> Content
    
    var display: Display = .flex
    var flexDirection: FlexDirection = .Row
    var justifyContent: JustifyContent = .FlexStart
    var alignmentItems: AlignItems = .Center
    
    // 是否支持换行，不换行会不断压缩
    var flexWrap: FlexWrap = .Wrap
    
    @State var sizeBody: CGSize? = nil
//    @State private var widthItems: [Item: CGFloat] = [:]
    
    init(flexDirection: FlexDirection = .Row,
         alignmentItems: AlignItems = .FlexStart,
         spacing: CGFloat = 0,
         items: [Item],
         viewList: [AnyView],
         @ViewBuilder content: @escaping (Int) -> Content) {
        self.flexDirection = flexDirection
        self.spacing = spacing
        self.items = items
        self.content = content
        self.alignmentItems = alignmentItems
        switch alignmentItems {
            case .FlexStart:
                self.alignment = .topLeading
                break
            case .FlexEnd:
                self.alignment = .topTrailing
                break
            case .Center:
                self.alignment = .center
                break
            default:
                self.alignment = .topLeading
        }
    }
    
    init(flexDirection: FlexDirection = .Row, alignmentItems: AlignItems = .FlexStart, spacing: CGFloat = 0, items: [Item], @ViewBuilder content: @escaping (Int) -> Content) {
        self.flexDirection = flexDirection
        self.spacing = spacing
        self.items = items
        self.content = content
        self.alignmentItems = alignmentItems
        switch alignmentItems {
            case .FlexStart:
                self.alignment = .topLeading
                break
            case .FlexEnd:
                self.alignment = .topTrailing
                break
            case .Center:
                self.alignment = .center
                break
            default:
                self.alignment = .topLeading
        }
    }
    
    init(alignment: Alignment = .center, spacing: CGFloat = 0, items: [Item], @ViewBuilder content: @escaping (Int) -> Content) {
        self.spacing = spacing
        self.alignment = alignment
        self.items = items
        self.content = content
    }
    
    init(flexDirection: FlexDirection = .Row, alignment: Alignment = .center, spacing: CGFloat = 0, items: [Item], @ViewBuilder content: @escaping (Int) -> Content) {
        self.flexDirection = flexDirection
        self.spacing = spacing
        self.alignment = alignment
        self.items = items
        self.content = content
    }
    
    var body: some View {
        self.contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: self.alignment)
            .background(
                GeometryReader { (geo) in
                    Color.clear.onAppear {
                        self.sizeBody = geo.frame(in: .global).size
//                        print(self.sizeBody)
                    }
                }
            )
    }
        
    private var contentView: some View {
        if self.flexDirection == .Row {
            return
                AnyView(
                HStack(alignment: self.alignment.vertical, spacing: self.spacing) {
                    ForEach(self.rowsIndices, id: \.self) { (row) in
                        self.content(row)
                    }
                })
            } else {
                return AnyView(
                    VStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
                        ForEach(self.rowsIndices, id: \.self) { (row) in
                            self.content(row)
                        }
                    }
                )
            }
    }
    
    private func createRow(index: Int) -> some View {
        return AnyView(
            self.content(index)
//            .background(
//                GeometryReader { (geo) in
//                    Color.clear.onAppear {
//                        let item = self.items[index]
//                        self.widthItems[item] = geo.frame(in: .global).size.width
//                    }
//                }
//            )
        )
    }
    
//    private func createRowWrap(indices: [Int]) -> some View {
//        if self.flexDirection == .Row {
//            return AnyView(
//                VStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
//                    ForEach(indices, id: \.self) { (index) in
//                        Group {
//                            self.content(index)
//                        }
////                        .background(
////                            GeometryReader { (geo) in
////                                Color.clear.onAppear {
////                                    self.widthItems[self.items[index]] = geo.frame(in: .global).size.width
////                                }
////                            }
////                        )
//                    }
//                }
//            )
//        } else {
//            return AnyView(
//                VStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
//                    ForEach(indices, id: \.self) { (index) in
//                        Group {
//                            self.content(index)
//                        }
////                        .background(
////                            GeometryReader { (geo) in
////                                Color.clear.onAppear {
////                                    self.widthItems[self.items[index]] = geo.frame(in: .global).size.width
////                                }
////                            }
////                        )
//                    }
//                }
//            )
//        }
//    }
    
    private var rowsIndices: [Int] {
        var rows: [Int] = []
        for index in 0 ..< items.count {
            rows.append(index)
        }
        return rows
    }
    
//    private var rowsIndicesWrap: [[Int]] {
//
//        guard let widthBody = self.sizeBody?.width else {
//            return self.items.indices.map { [ $0 ] }
//        }
//
//        var rowWidth: CGFloat = 0
//        var rowItems: [Int] = []
//        var rows: [[Int]] = []
//
//        for index in 0 ..< items.count {
//            if  let widthItem = self.widthItems[self.items[index]] {
//                let rowWidthNext = rowWidth + widthItem + (rowItems.isEmpty ? 0 : self.spacing)
//                if rowWidthNext <= widthBody {
//                    rowItems.append(index)
//                    rowWidth = rowWidthNext
//                }
//                else {
//                    if rowItems.isEmpty == false {
//                        rows.append(rowItems)
//                        rowWidth = 0
//                        rowItems = []
//                    }
//                    rowWidth = widthItem
//                    rowItems = [ index ]
//                }
//            }
//            else {
//                if rowItems.isEmpty == false {
//                    rows.append(rowItems)
//                    rowWidth = 0
//                    rowItems = []
//                }
//                rows.append([ index ])
//            }
//        }
//        if rowItems.isEmpty == false {
//            rows.append(rowItems)
//            rowWidth = 0
//            rowItems = []
//        }
//        print(rows)
//        return rows
//    }
}
