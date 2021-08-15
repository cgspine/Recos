//
//  RecosExtension.swift
//  Recos
//
//  Created by wenhuan on 2021/7/21.
//

import Foundation
import SwiftUI

// MARK: UIColor

extension UIColor {
    public convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var hex:   String = hex

        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }

        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
            }
        } else {
            print("Scan hex error")
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

//// MARK: View
//
//extension View {
//    func `if`<TrueContent>(_ condition: Bool, @ViewBuilder  transform: @escaping (Self) -> TrueContent)
//        -> ConditionalWrapper1<Self, TrueContent> where TrueContent: View {
//            ConditionalWrapper1<Self, TrueContent>(content: { self },
//                                                   conditional: Conditional<Self, TrueContent>(condition: condition,
//                                                                                               transform: transform))
//    }
//
//    func `if`<TrueContent: View, Item>(`let` item: Item?, @ViewBuilder transform: @escaping (Self, Item) -> TrueContent)
//        -> ConditionalWrapper1<Self, TrueContent> {
//            if let item = item {
//                return self.if(true, transform: {
//                    transform($0, item)
//                })
//            } else {
//                return self.if(false, transform: {
//                    transform($0, item!)
//                })
//            }
//    }
//}
//
//struct Conditional<Content: View, Trans: View> {
//    let condition: Bool
//    let transform: (Content) -> Trans
//}
//
//struct ConditionalWrapper1<Content: View, Trans1: View>: View {
//    var content: () -> Content
//    var conditional: Conditional<Content, Trans1>
//
//    func elseIf<Trans2: View>(_ condition: Bool, @ViewBuilder transform: @escaping (Content) -> Trans2)
//        -> ConditionalWrapper2<Content, Trans1, Trans2> {
//            ConditionalWrapper2(content: content,
//                                conditionals: (conditional,
//                                               Conditional(condition: condition,
//                                                           transform: transform)))
//    }
//
//    func elseIf<Trans2: View, Item>(`let` item: Item?, @ViewBuilder transform: @escaping (Content, Item) -> Trans2)
//        -> ConditionalWrapper2<Content, Trans1, Trans2> {
//            let optionalConditional: Conditional<Content, Trans2>
//            if let item = item {
//                optionalConditional = Conditional(condition: true) {
//                    transform($0, item)
//                }
//            } else {
//                optionalConditional = Conditional(condition: false) {
//                    transform($0, item!)
//                }
//            }
//            return ConditionalWrapper2(content: content,
//                                       conditionals: (conditional, optionalConditional))
//    }
//
//    func `else`<ElseContent: View>(@ViewBuilder elseTransform: @escaping (Content) -> ElseContent)
//        -> ConditionalWrapper2<Content, Trans1, ElseContent> {
//            ConditionalWrapper2(content: content,
//                                conditionals: (conditional,
//                                               Conditional(condition: !conditional.condition,
//                                                           transform: elseTransform)))
//    }
//
//    var body: some View {
//        Group {
//            if conditional.condition {
//                conditional.transform(content())
//            } else {
//                content()
//            }
//        }
//    }
//}
//
//struct ConditionalWrapper2<Content: View, Trans1: View, Trans2: View>: View {
//    var content: () -> Content
//    var conditionals: (Conditional<Content, Trans1>, Conditional<Content, Trans2>)
//
//    func `else`<ElseContent: View>(@ViewBuilder elseTransform: (Content) -> ElseContent) -> some View {
//        Group {
//            if conditionals.0.condition {
//                conditionals.0.transform(content())
//            } else if conditionals.1.condition {
//                conditionals.1.transform(content())
//            } else {
//                elseTransform(content())
//            }
//        }
//    }
//
//    var body: some View {
//        self.else { $0 }
//    }
//}
//
