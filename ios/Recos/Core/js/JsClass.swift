//
//  JsClass.swift
//  Recos
//
//  Created by wenhuan on 2021/7/21.
//

import Foundation
import SwiftUI
import UIKit

enum VariableKind: String {
    case LET = "let"
    case CONST = "const"
    case VAR = "var"
}

struct JsStyle {
    
    var backgroundColor: Color = .clear
    
    var textAlign: Alignment = .leading
    var borderColor: Color = .clear
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var lineHeight: CGFloat = 0
    var letterSpacing: CGFloat = 0
    
    var margin: CGFloat = 0
    var marginLeft: CGFloat = 0
    var marginRight: CGFloat = 0
    var marginTop: CGFloat = 0
    var marginBottom: CGFloat = 0
    
    var borderRadius: CGFloat = 0
    
    var fontSize: CGFloat = 14
    var fontWeight: Font.Weight = .regular
    var font: Font = Font.system(size: 14)
    var fontColor: Color = .black
    
    var borderTopColor: Color = .clear
    var borderRightColor: Color = .clear
    var borderBottomColor: Color = .clear
    var borderLeftColor: Color = .clear
    
    var shadowColor: Color = .clear
}

class JsStackFrame {
    public var scope: JsScope?
    var updateState: ((Int, Any?) -> Void)?
    var visitAndGetState: ((Any?) -> [Int : Any?])?
    var visitAndGetCallback: ((JsFunctionDecl) -> JsFunctionDecl)?
    var checkAndRunEffect: ((JsFunctionDecl, JsArray) -> Void)?
    var returnValue: Any? = NSNull.init()
    
    init(parentScope: JsScope?) {
        scope = JsScope(parentScope: parentScope)
    }
}

class JsScope {
    var varList: [String : Any] = [:]
    var functionList: [String : FunctionDecl] = [:]
    var parentScope: JsScope?
    var extraVarList: [String : Any] = [:]
    
    init(parentScope: JsScope?) {
        self.parentScope = parentScope
    }
    
    func getVar(variable: String) -> Any? {
        if (varList[variable] != nil) {
            return varList[variable]
        }
        return parentScope?.getVar(variable: variable)
    }
    
    func addVar(variable: JsVariable) {
        // TODO try catch
        if variable.value == nil {
            varList[variable.name] = NSNull()
        } else {
            varList[variable.name] = variable
        }
    }
    
    func getExtraVar(variable: String) -> Any? {
        if (extraVarList[variable] != nil) {
            return extraVarList[variable]
        }
        return parentScope?.getExtraVar(variable: variable)
    }
    
    func setExtraVar(variable: JsVariable?) {
        if variable == nil {
            return
        }
        if variable?.value == nil {
            extraVarList[variable!.name] = NSNull()
        } else {
            extraVarList[variable!.name] = variable
        }
    }
    
    func removeExtraVar(name: String) {
        extraVarList[name] = NSNull()
    }
    
    func setExtraVarToHeadScope(variable: JsVariable) {
        var headScope = self.parentScope
        while (headScope != nil) && (headScope!.parentScope != nil) {
            headScope = headScope?.parentScope
        }
        if variable.value == nil {
            headScope?.extraVarList[variable.name] = NSNull()
        } else {
            headScope?.extraVarList[variable.name] = variable
        }
    }
    
    func getExtraVarWithHeadScope(name: String) -> Any? {
        var headScope = self.parentScope
        while (headScope != nil) && (headScope!.parentScope != nil) {
            headScope = headScope?.parentScope
        }
        return headScope?.extraVarList[name]
    }
    
    func addFunction(functionDecl: FunctionDecl) {
        functionList[functionDecl.name] = functionDecl
    }
    
    func getFunction(name: String) -> FunctionDecl? {
        return functionList[name] ?? parentScope?.getFunction(name: name)
    }
}

public class JsFunctionDecl {
    var name: String
    var param: [Node]
    var body: Node
    var parentScope: JsScope? = nil
    var isRecosComponent: Bool = false
    
    init(name: String, param: [Node], body: Node, parentScope: JsScope? = nil, isRecosComponent: Bool = false) {
        self.name = name
        self.param = param
        self.body = body
        self.parentScope = parentScope
        self.isRecosComponent = isRecosComponent
    }
}

typealias MemberInvoker = (Any?) -> (Void)

protocol MemberProvider {
    func getMemeber(name: String) -> Any?
    func memberSetter(name: String) -> MemberInvoker
}

//protocol JsMemberProvider {
//    func getMemberValue(name: Any) -> Any?
//    func setMemberValue(name: Any, value: Any?)
//}

class NativeMemberInvoker {
    var myCompletionHandler: (_ args: [Any?]?) -> (Any?)
    
    init(completion: @escaping completionHandler) {
        self.myCompletionHandler = completion
    }

    func call(args: [Any?]?) -> Any? {
        return myCompletionHandler(args)
    }
}

class JsEffect {
    var function: JsFunctionDecl
    var lastValueList: JsArray?
    
    init(function: JsFunctionDecl, lastValueList: JsArray?) {
        self.function = function
        self.lastValueList = lastValueList
    }
}

class JsObject: MemberProvider {
    var fields = [String : Any?]()

    func getValue(variable: String) -> Any? {
        return fields[variable] as Any?
    }
    
    func setValue(variable: String, value: Any?) -> Void {
        fields[variable] = value
    }
    
    func getMemeber(name: String) -> Any? {
        return fields[name] as Any?
    }
    
    func memberSetter(name: String) -> MemberInvoker {
        let memberInvoker: MemberInvoker = {(it: Any?) -> Void in
            self.fields[name] = it
        }
        return memberInvoker
    }
    
    func toJsStyle() -> JsStyle {
        var jsStyle = JsStyle()

        let width = CGFloat(self.getValue(variable: "width") as? Float ?? 0)
        let height = CGFloat(self.getValue(variable: "height") as? Float ?? 0)
        jsStyle.width = width == 0 ? nil : width
        jsStyle.height = height == 0 ? nil : height
        jsStyle.lineHeight = CGFloat(self.getValue(variable: "lineHeight") as? Float ?? 0)
        jsStyle.letterSpacing = CGFloat(self.getValue(variable: "letterSpacing") as? Float ?? 0)
        
        jsStyle.margin = CGFloat(self.getValue(variable: "margin") as? Float ?? 0)
        jsStyle.marginLeft = CGFloat(self.getValue(variable: "marginLeft") as? Float ?? 0)
        jsStyle.marginRight = CGFloat(self.getValue(variable: "marginRight") as? Float ?? 0)
        jsStyle.marginTop = CGFloat(self.getValue(variable: "marginTop") as? Float ?? 0)
        jsStyle.marginBottom = CGFloat(self.getValue(variable: "marginBottom") as? Float ?? 0)
        
        jsStyle.fontSize = CGFloat(self.getValue(variable: "fontSize") as? Float ?? 0)
        let fontColorValue = self.getValue(variable: "color")
        if fontColorValue != nil {
            jsStyle.fontColor = Color(UIColor.init(hex: fontColorValue as! String))
        }
        
        let fontWeightValue = self.getValue(variable: "fontWeight") as? String
        if (fontWeightValue != nil) {
            switch fontWeightValue! {
            case "bold":
                jsStyle.fontWeight = .bold
            case "light":
                jsStyle.fontWeight = .light
            case "medium":
                jsStyle.fontWeight = .medium
            case "normal":
                jsStyle.fontWeight = .regular
            default:
                jsStyle.fontWeight = .regular
            }
        }
        
        let font = Font.system(size: jsStyle.fontSize, weight: jsStyle.fontWeight)
        jsStyle.font = font
        
        let backgroundColorValue = self.getValue(variable: "backgroundColor") as? String
        if (backgroundColorValue != nil) {
            jsStyle.backgroundColor = Color(UIColor.init(hex: backgroundColorValue!))
        }

        let borderRadius = self.getValue(variable: "borderRadius") as? Float ?? 0
        jsStyle.borderRadius = CGFloat(borderRadius)
        
        let borderColorValue = self.getValue(variable: "borderColor") as? String
        if borderColorValue != nil {
            jsStyle.borderColor = Color(UIColor.init(hex: borderColorValue!))
        }

        let borderTopColorValue = self.getValue(variable: "borderTopColor") as? String
        if borderTopColorValue != nil {
            jsStyle.borderTopColor = Color(UIColor.init(hex: borderTopColorValue!))
        }

        let borderRightColorValue = self.getValue(variable: "borderRightColor") as? String
        if borderRightColorValue != nil {
            jsStyle.borderRightColor = Color(UIColor.init(hex: borderRightColorValue!))
        }

        let borderBottomColorValue = self.getValue(variable: "borderBottomColor") as? String
        if borderBottomColorValue != nil {
            jsStyle.borderBottomColor = Color(UIColor.init(hex: borderBottomColorValue!))
        }

        let borderLeftColorValue = self.getValue(variable: "borderLeftColor") as? String
        if borderLeftColorValue != nil {
            jsStyle.borderLeftColor = Color(UIColor.init(hex: borderLeftColorValue!))
        }

        let shadowColorValue = self.getValue(variable: "shadowColor") as? String
        if shadowColorValue != nil {
            jsStyle.shadowColor = Color(UIColor.init(hex: shadowColorValue!))
        }
        
        return jsStyle
    }
}

typealias completionHandler = (_ args: [Any?]?) -> (Any?)

class JsArray: MemberProvider {
    var list = [Any?]()
    
    func push(item: Any?) -> Void {
        list.append(item)
    }
    
    func get(index: Int) -> Any? {
        return list[index]
    }
    
    func getMemeber(name: String) -> Any? {
        switch name {
        case "push":
            let object = NativeMemberInvoker { arg in
                arg?.forEach({ it in
                    self.list.append(it)
                })
            }
            return object
        case "length":
            return list.count
        default:
            let index: Int = Int(name) ?? 0
            if index < list.count {
                return list[index]
            }
            assert(false, "array out of bounds")
        }
    }
    
    func memberSetter(name: String) -> MemberInvoker {
        let memberInvoker: MemberInvoker = {(it: Any?) -> Void in
            self.list[Int(name) ?? 0] = it
        }
        return memberInvoker
    }
    
//    static func != (lhs: JsArray, rhs: JsArray) -> Bool {
//        if lhs.list.count != rhs.list.count {
//            return true
//        }
//        for (index, value) in lhs.list.enumerated() {
//            if value as! JsObject != rhs.list[index] as! JsObject {
//                return true
//            }
//        }
//        return false
//    }
//
    static func == (lhs: JsArray, rhs: JsArray) -> Bool {
        if lhs.list.count != rhs.list.count {
            return false
        }
        for (index, value) in lhs.list.enumerated() {
            if (value as! JsObject) as! AnyHashable != (rhs.list[index] as! JsObject) as! AnyHashable {
                return false
            }
        }
        return true
    }
}

class JsVariable {
    var name: String
    var kind: VariableKind
    var value: Any?
    
    init(name: String, kind: VariableKind, value: Any? = nil) {
        self.name = name
        self.kind = kind
        self.value = value
    }
    
    func getValue() -> Any? {
        return self.value
    }
    
    func updateValue(value: Any?) -> Void {
        self.value = value
    }
}

class JsMember {
    var obj: MemberProvider
    var name: String
    
    init(obj: MemberProvider, name: String) {
        self.obj = obj
        self.name = name
    }
}
