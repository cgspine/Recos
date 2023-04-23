//
//  DefaultFlexBoxDataSource.swift
//  Recos
//
//  Created by wenhuan on 2021/8/4.
//

import Foundation
import SwiftUI

class DefaultFlexBoxDataSource : FlexBoxDataSource {
    let data: [JsxRenderElement]
    @State var items: [String]
    
    init(data: [JsxRenderElement], items: [String]) {
        self.data = data
        self.items = items
    }
    
    func getItems() -> [String] {
        return self.items
    }
        
    func getAnyView(index: Int) -> AnyView {
        let item = self.data[index]
        return AnyView(item.Render())
    }
}

struct DefaultFlexBoxView: View {
    @State var keys: [String]
    let data: [JsxRenderElement]
    let style: JsObject?
    @State var recosFrame: CGRect?
    
    var paddingValue: CGFloat = 0
    // 布局方向
    var flexDirection: FlexDirection = .Row
    // 列方向
    var alignItems: AlignItems = .Center
    // 行方向
    var justifyContent: JustifyContent = .FlexStart
    // 是单行布局还是多行布局
    var flexWrap: FlexWrap = .NoWrap
    var backgroundColor: Color = .clear
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    init(keys: [String], data: [JsxRenderElement], style: JsObject?) {
        self.keys = keys
        self.data = data
        self.style = style
        
        let paddingValue = self.style?.getValue(variable: "margin") as? Float ?? 0
        self.paddingValue = CGFloat(paddingValue)
        
        let directionString = self.style?.getValue(variable: "flexDirection") as? String
        var flexDirection: FlexDirection = .Row
        if directionString != nil {
            flexDirection = self.getFlexDirection(direction: directionString!)
        }
        self.flexDirection = flexDirection
        
        let alignItemsString = self.style?.getValue(variable: "alignItems") as? String
        var alignItems: AlignItems = .FlexStart
        if alignItemsString != nil {
            alignItems = self.getAlignItems(alignItems: alignItemsString!)
        }
        self.alignItems = alignItems
        
        let justifyContentString = self.style?.getValue(variable: "justifyContent") as? String
        var justifyContent: JustifyContent = .FlexStart
        if justifyContentString != nil {
            justifyContent = self.getJustifyContent(justifyContent: justifyContentString!)
        }
        self.justifyContent = justifyContent
        
        let flexWrapString = self.style?.getValue(variable: "flexWrap") as? String
        var flexWrap: FlexWrap = .NoWrap
        if flexWrapString != nil {
            flexWrap = self.getFlexWrap(flexWrap: flexWrapString!)
        }
        self.flexWrap = flexWrap
        
        let backgroundColorString = self.style?.getValue(variable: "backgroundColor") as? String
        if let backgroundColorString = backgroundColorString {
            self.backgroundColor = Color(UIColor.init(hex: backgroundColorString))
        }
        
        let width = self.style?.getValue(variable: "width") as? Int
        if width ?? 0 > 0 {
            self.width = CGFloat(width ?? 0)
        } else {
            let width = self.style?.getValue(variable: "width") as? Float
            if width ?? 0 > 0 {
                self.width = CGFloat(width ?? 0)
            }
        }
        
        let height = self.style?.getValue(variable: "height") as? Int
        if height ?? 0 > 0 {
            self.height = CGFloat(height ?? 0)
        } else {
            let height = self.style?.getValue(variable: "height") as? Float
            if height ?? 0 > 0 {
                self.height = CGFloat(height ?? 0)
            }
        }
    }
    
    var body: some View {
        // margin外边距，就是自己
        // padding内边距
        RecosFlexBoxView(flexDirection: self.flexDirection,
                         alignmentItems: self.alignItems,
                         spacing: 0,
                         items: self.keys,
                         content: self.getAnyView(index:))
            .padding(self.paddingValue)
            .frame(width: self.width, height: self.height)
            .background(self.backgroundColor)
    }
    
    func getFlexDirection(direction: String) -> FlexDirection {
        switch direction {
            case "row":
                return .Row
            case "column":
                return .Column
            default:
                return .Row
        }
    }
    
    func getAlignItems(alignItems: String) -> AlignItems {
        switch alignItems {
        case "center":
            return .Center
        case "flex-start":
            return .FlexStart
        case "flex-end":
            return .FlexEnd
        default:
            return .FlexStart
        }
    }
    
    func getJustifyContent(justifyContent: String) -> JustifyContent {
        switch justifyContent {
        case "flex-start":
            return .FlexStart
        case "center":
            return .Center
        case "flex-end":
            return .FlexEnd
        case "space-between":
            return .SpaceBetween
        case "space-around":
            return .SpaceAround
        default:
            return .FlexStart
        }
    }
    
    func getFlexWrap(flexWrap: String) -> FlexWrap {
        switch flexWrap {
        case "nowrap":
            return .NoWrap
        case "wrap":
            return .Wrap
        default:
            return .NoWrap
        }
    }
    
    func getAnyView(index: Int) -> AnyView {
        let item = self.data[index]
        return AnyView(item.Render())
    }
}
