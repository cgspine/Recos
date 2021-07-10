//
//  SwiftUIJsEvaluator.swift
//  Example
//
//  Created by tigerAndBull on 2021/5/26.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftUI

public struct Stack<T> {
     fileprivate var array = [T]()
     public var isEmpty: Bool {
         return array.isEmpty
     }
     public var count: Int {
        return array.count
     }
     public mutating func push(_ element: T) {
        array.append(element)
     }
    
    @discardableResult
     public mutating func pop() -> T? {
        return array.popLast()
     }
     public var top: T? {
        return array.last
     }
}

class JsEvaluator {
    
    var dataSource: DefaultRecosDataSource
    
    init(dataSource: DefaultRecosDataSource) {
        self.dataSource = dataSource
    }
    
    private var TAG = "ComposeJsEvaluator"
    var rootScope = Scope(parentScope: nil)
    var stack = Stack<StackFrame>()
    
    func getArgs(nodes: [Node], index: Int) -> [String : Any]? {
        var result: [String : Any] = [:]
        nodes.forEach { node in
            if node.type == TYPE_EXPR_ID {
                let name = (node.content as! IdInfo).name
                result[name] = index
            }
        }
        return result
    }
    
    func normalEval(functionDecl: FunctionDecl, parentScope: Scope?, args: [String : Any]?, selfValue: Any?) -> Void {
        let lastFrame = stack.top
        let frame = StackFrame(parentScope: (parentScope != nil) ? parentScope! : rootScope, prevFrame: lastFrame)
        args?.forEach { it in
            frame.scope?.setVar(variable: it.key, value: it.value)
        }
        frame.scope?.setVar(variable: "this", value: selfValue)
        stack.push(frame)
        let body = functionDecl.body
        normalExel(node: body, scope: frame.scope!)
        stack.pop()
    }
    
    func normalExel(node: Node, scope: Scope) -> Void {
        switch node.type {
            case TYPE_DECL_VAR_LIST:
                let nodeArray = node.content as! [Node]
                nodeArray.forEach { it in
                    if it.type == TYPE_DECL_VAR {
                        let varItem = it.content as! ValDecl
                        scope.setVar(variable: varItem.name, value: parseExprValue(value:varItem.initNode, scope:scope))
                    } else if it.type == TYPE_DECL_VAR_ARRAY_PATTERN {
                        let varList = it.content as! ArrayPatternValDecl
                        let initValue = parseExprValue(value: varList.initNode, scope: scope)
                        for (index, name) in varList.nameList.enumerated() {
                            scope.setVar(variable: name, value: (initValue as! JsArray).get(index: index))
                        }
                    }
                }
                break
            case TYPE_DECL_FUNC:
                // TODO
                break
            case TYPE_STATEMENT_BLOCK:
                // TODO
                let nodeArray = node.content as! [Node]
                for item in nodeArray {
                    normalExel(node: item, scope: scope)
                }
                break
            case TYPE_STATEMENT_FOR:
                // TODO
                let forStatement = node.content as! ForStatement
                let forScope = Scope(parentScope: scope)
                normalExel(node: forStatement.initNode, scope: forScope)
                while parseExprValue(value: forStatement.test, scope: forScope) as? Bool == true {
                    normalExel(node: forStatement.body, scope: forScope)
                    normalExel(node: forStatement.update, scope: forScope)
                }
                break
            case TYPE_EXPR_UPDATE:
                parseExprValue(value: node, scope: scope)
                // TODO
                break
            case TYPE_STATEMENT_IF:
                let ifStatement = node.content as! IfStatement
                let ifScope = Scope(parentScope: scope)
                if parseExprValue(value: ifStatement.test, scope: ifScope) as? Bool == true {
                    normalExel(node: ifStatement.consequent, scope: ifScope)
                } else {
                    normalExel(node: ifStatement.alternate, scope: ifScope)
                }
                // TODO
                break
            case TYPE_STATEMENT_RETURN:
                let arg = node.content as! Node
                normalExel(node: arg, scope: scope)
                // TODO
                break
            case TYPE_STATEMENT_EXPR:
                // TODO
                parseExprValue(value: node.content as! Node, scope: scope)
                break
            default:
                break
        }
    }
    
    func Eval(functionDecl: FunctionDecl, parentScope: Scope?, args: [String : Any]?, recosObserveObject: RecosObservedObject) -> AnyView? {
        let lastFrame = stack.top
        let frame = StackFrame(parentScope: (parentScope != nil) ? parentScope! : rootScope, prevFrame: lastFrame)
        args?.forEach { it in
            frame.scope?.setVar(variable: it.key, value: it.value)
        }
        stack.push(frame)
        let body = functionDecl.body
        var view : AnyView?
        view = Exec(node: body, scope: frame.scope!, view: &view, recosObserveObject: recosObserveObject)
        stack.pop()
        return view
    }
    
    func Exec(node: Node, scope: Scope, view: inout AnyView?, recosObserveObject: RecosObservedObject) -> AnyView? {
        switch node.type {
        case TYPE_DECL_VAR_LIST:
            let nodeArray = node.content as! [Node]
            for item in nodeArray {
                if item.type == TYPE_DECL_VAR {
                    let varItem = item.content as! ValDecl
                    let value = parseExprValue(value: varItem.initNode, scope: scope)
                    scope.setVar(variable: varItem.name, value: value)
                } else if item.type == TYPE_DECL_VAR_ARRAY_PATTERN {
                    let varList = item.content as! ArrayPatternValDecl
                    let initValue = parseExprValue(value: varList.initNode, scope: scope)
                    for (index, name) in varList.nameList.enumerated() {
                        scope.setVar(variable: name, value: (initValue as! JsArray).get(index: index))
                    }
                }
            }
            return view
        case TYPE_DECL_FUNC:
            // TODO
            break
        case TYPE_STATEMENT_BLOCK:
            // TODO block scope to support let/var
            let nodeArray = node.content as! [Node]
            for item in nodeArray {
                view = Exec(node: item, scope: scope, view: &view, recosObserveObject: recosObserveObject)
            }
            return view
        case TYPE_STATEMENT_FOR:
            let forStatement = node.content as! ForStatement
            let forScope = Scope(parentScope: scope)
            view = Exec(node: forStatement.initNode, scope: forScope, view: &view, recosObserveObject: recosObserveObject)
            while parseExprValue(value: forStatement.test, scope: forScope) as? Bool == true {
                view = Exec(node: forStatement.body, scope: forScope, view: &view, recosObserveObject: recosObserveObject)
                view = Exec(node: forStatement.update, scope: forScope, view: &view, recosObserveObject: recosObserveObject)
            }
            return view
        case TYPE_EXPR_UPDATE:
            parseExprValue(value: node, scope: scope)
            break
        case TYPE_STATEMENT_IF:
            let ifStatement = node.content as! IfStatement
            let ifScope = Scope(parentScope: scope)
            if parseExprValue(value: ifStatement.test, scope: ifScope) as? Bool == true {
                view = Exec(node: ifStatement.consequent, scope: ifScope, view: &view, recosObserveObject: recosObserveObject)
            } else {
                view = Exec(node: ifStatement.alternate, scope: ifScope, view: &view, recosObserveObject: recosObserveObject)
            }
            return view
        case TYPE_STATEMENT_RETURN:
            // TODO not use jsx???, use special function?
            // TODO normal return value.
            let arg = node.content as! Node
            if arg.type == TYPE_JSX_ELEMENT {
                view = Exec(node: arg, scope: scope, view: &view, recosObserveObject: recosObserveObject)
                return view
            } else if arg.type == TYPE_EXPR_CALL {
                let callExpr = arg.content as! CallExpr
                let memeberFunc = parseExprValue(value: callExpr.callee, scope: scope)
                if memeberFunc is FunctionDecl {
                    let functionDecl = (memeberFunc as! FunctionDecl)
                    var args: [String : Any] = [:]
                    let params = functionDecl.params
                    for (index, node) in params.enumerated() {
                        let name = (node.content as! IdInfo).name
                        let value = parseExprValue(value: callExpr.arguments[index], scope: scope)
                        args[name] = value
                    }
                    view = Eval(functionDecl: functionDecl, parentScope: scope, args: args, recosObserveObject: recosObserveObject)
                    return view
                }
            }
            view = Exec(node: arg, scope: scope, view: &view, recosObserveObject: recosObserveObject)
            return view
        case TYPE_JSX_ELEMENT:
            let jsxElement = node.content as! JsxElement
            var props: [String : Any?] = [:]
            
            jsxElement.props.forEach({ item in
                let value = parseExprValue(value: item.value, scope: scope)
                props[item.name] = value
            })
            
            if jsxElement.name == "RecyclerView" {
                let count = props["count"] as? Int ?? 0
                if count == 0 {
                    return view
                } else {
                    let list = List {
                        ForEach(0..<count) { index in
                            let child = (props["render"] as? FunctionExpr)?.toFunctionDecl()
                            let args = child?.params
                            let result = self.getArgs(nodes: args!, index: index)
                            if (child != nil) {
                                EvalView(functionDecl: child!, parentScope: scope, args: result, evaluator: self)
                            }
                        }
                    }
                    return AnyView(list)
                }
            } else if jsxElement.name == "Text" {
                var string = String()
                jsxElement.children.forEach { item in
                    if item.type == TYPE_JSX_TEXT {
                        let jsxText = item.content as! JsxText
                        string.append(jsxText.text)
                    } else {
                        let value = parseExprValue(value: item, scope: scope)
                        if (value != nil) {
                            if value is Float {
                                string.append(String(value as! Float))
                            } else if value is Int {
                                string.append(String(value as! Int))
                            } else {
                                string.append(value as! String)
                            }
                        }
                    }
                }
                print("Text: " + string)
                let functionDecl = (props["onClick"] as? Function)?.toFunctionDecl()
                let text = Text(string).onTapGesture {
                    print("点击了text")
                    scope.parentScope?.parentScope?.parentScope?.setVar(variable: "needUpdate", value: true)
                    self.normalEval(functionDecl: functionDecl!, parentScope: scope, args: nil, selfValue: nil)
                }
                return AnyView(text)
            }
            break
        case TYPE_STATEMENT_EXPR:
            parseExprValue(value: node.content as! Node, scope: scope)
            return view
        default:
            return view
        }
        return view
    }
    
    func ExecWithState(functionDecl: FunctionDecl,
                       parentScope: Scope?,
                       args: [String : Any]?,
                       recosObserveObject: RecosObservedObject) -> AnyView? {
        var currentStateIndex: Int = -1
        var currentCallbackIndex: Int = -1
        var currentEffectIndex: Int = -1
        let lastFrame = stack.top
        let frame = StackFrame(parentScope: (parentScope != nil) ? parentScope! : rootScope, prevFrame: lastFrame)
        
        var state = recosObserveObject.state
        var callBack = recosObserveObject.callBack
        var effectList = recosObserveObject.effectList
        
        frame.scope?.visitAndGetState = {(defaultValue: Any) -> [Int : Any?] in
            currentStateIndex += 1
            if state.count > currentStateIndex {
                var args: [Int : Any] = [:]
                args[currentStateIndex] = state[currentStateIndex]
                return args
            } else {
                state.append(defaultValue)
                var args: [Int : Any] = [:]
                args[currentStateIndex] = defaultValue
                return args
            }
        }
        
        frame.scope?.updateState = {(index: Int, value: Any?) -> Void in
            state[index] = value
            let needUpdate = frame.scope?.getVar(variable: "needUpdate") as? Bool ?? false
            recosObserveObject.updateState(value: state, needUpdate: needUpdate)
        }

        frame.scope?.visitAndGetCallback = {(defaultValue: Function) -> Function in
            currentCallbackIndex += 1
            if callBack.count > currentCallbackIndex {
                return callBack[currentCallbackIndex]
            } else {
                callBack.append(defaultValue)
                return defaultValue
            }
        }
        
        frame.scope?.checkAndRunEffect = {(defaultValue: Function, deps: JsArray) -> Void in
            currentEffectIndex += 1
            if effectList.count > currentEffectIndex {
                let effect = effectList[currentEffectIndex]
                if effect.lastValueList! == deps {
                    effectList[currentEffectIndex] = JsEffect(function: defaultValue, lastValueList: deps)
                    self.normalEval(functionDecl: defaultValue.toFunctionDecl() , parentScope: frame.scope, args: nil, selfValue: nil)
                }
            } else {
                effectList.append(JsEffect(function: defaultValue, lastValueList: deps))
                self.normalEval(functionDecl: defaultValue.toFunctionDecl() , parentScope: frame.scope, args: nil, selfValue: nil)
            }
        }
        
        args?.forEach({ arg in
            frame.scope?.setVar(variable: arg.key, value: arg.value)
        })
        
        stack.push(frame)
        let body = functionDecl.body
        var view : AnyView?
        view = Exec(node: body, scope: frame.scope!, view: &view, recosObserveObject: recosObserveObject)
        stack.pop()
        return view
    }
    
    @discardableResult
    func parseExprValue(value: Node, scope: Scope, leftValue: Bool = false) -> Any? {

        if value.type == TYPE_LITERAL_STR {
            return (value.content as! StringLiteral).value
        }else if(value.type == TYPE_LITERAL_NUM) {
            let value = (value.content as! NumLiteral).value
            return value
        }else if(value.type == TYPE_EXPR_FUNCTION){
            return value.content as! FunctionExpr
        }else if(value.type == TYPE_EXPR_ARRAY_FUNCTION) {
            return value.content as! FunctionArrayExpr
        }else if(value.type == TYPE_EXPR_ARRAY) {
            let ret = JsArray()
            let nodeArray = value.content as! [Node]
            for item in nodeArray {
                let it = parseExprValue(value: item, scope: scope)
                ret.push(item: it)
            }
            return ret
        }else if(value.type == TYPE_EXPR_BINARY) {
            return binaryCalculate(scope: scope, binaryData: value.content as! BinaryData)
        }else if(value.type == TYPE_EXPR_ID){
            let name = (value.content as! IdInfo).name
            switch name {
            case "useState":
                let object = NativeMemberInvoker { args in
                    let statusValue = scope.visitAndGetState!(args?[0]!) as [Int : Any]
                    let index = Array(statusValue.keys)[0]
                    let array = JsArray()
                    array.push(item: statusValue[0])
                    let invoker = NativeMemberInvoker { args in
                        scope.updateState!(index, args?[0]!)
                    }
                    array.push(item: invoker)
                    return array
                }
                return object
            case "useCallback":
                var callBack : Function?
                let object = NativeMemberInvoker { args in
                    callBack = scope.visitAndGetCallback!(args?[0]! as! Function)
                    return callBack
                }
                return object
            case "useEffect":
                let object = NativeMemberInvoker { args in
                    let function = args?[0] as! FunctionArrayExpr
                    let jsArray = args?[1] as! JsArray
                    scope.checkAndRunEffect!(function, jsArray)
                    return nil
                }
                return object
            default:
                let functionDecl = dataSource.getExitModule(modleName: name)
                if (functionDecl != nil) {
                    return functionDecl
                }
                return scope.getVar(variable: name)
            }
        } else if(value.type == TYPE_EXPR_OBJECT) {
            let properties = value.content as! [ObjectProperty]
            let obj = JsObject()
            properties.forEach { property in
                var key: Any?
                if property.computed {
                    key = parseExprValue(value: property.key, scope: scope)
                } else {
                    if property.key.type == TYPE_EXPR_ID {
                        let idInfo = property.key.content as! IdInfo
                        key = idInfo.name
                    }
                }
                let pValue = parseExprValue(value: property.value, scope: scope)
                if (key != nil) {
                    obj.setValue(variable: key as! String, value: pValue)
                }
            }
            return obj
        }else if(value.type == TYPE_EXPR_CALL) {
            
            let callExpr = value.content as! CallExpr
            let memberFunc = parseExprValue(value: callExpr.callee, scope: scope)
            var arguments = [Any?]()
            callExpr.arguments.forEach { item in
                arguments.append(parseExprValue(value: item, scope: scope))
            }
            
            if memberFunc is NativeMemberInvoker {
                let invoker = memberFunc as! NativeMemberInvoker
                return invoker.call(args: arguments)
            }
            
            if memberFunc is Function {
                let functionDecl = (memberFunc as! Function).toFunctionDecl()
                let params = functionDecl.params
                var args: [String : Any] = [:]
                for (index, node) in params.enumerated() {
                    let name = (node.content as! IdInfo).name
                    args[name] = arguments[index]
                }
                return normalEval(functionDecl: functionDecl, parentScope: scope, args: args, selfValue: nil)
            }
            
            return memberFunc
            
        } else if(value.type == TYPE_EXPR_MEMBER) {
            
            let memberExpr = value.content as! MemeberExpr
            
            let obj = parseExprValue(value: memberExpr.obj, scope: scope)
            if obj is MemberProvider {
                if leftValue {
                    let ret = parseMemberGetter(obj: obj as! MemberProvider, computed: memberExpr.computed, value: memberExpr.property, scope: scope)
                    return ret
                }
                let ret = parseMember(obj: obj as! MemberProvider, computed: memberExpr.computed, value: memberExpr.property, scope: scope)
                return ret
            }
            assert(false, "can not be empty")
            return nil
        } else if(value.type == TYPE_EXPR_UPDATE) {
            let updateExpr = value.content as! UpdateExpr
            let argumentName = updateExpr.argument.content as! IdInfo
            let cv = scope.getVar(variable: argumentName.name)
            var intCV = Int(0)
            if cv is Float {
                intCV = Int(cv as! Float)
            }else {
                intCV = cv as! Int
            }
            let currentValue: Int = intCV
            var nextValue: Int = currentValue
            switch updateExpr.operatorString {
            case "++":
                nextValue += 1
            case "--":
                nextValue -= 1
            default:
                nextValue += 1
            }
            print(String(nextValue))
            scope.setVar(variable: argumentName.name, value: nextValue)
            if updateExpr.prefix {
                return Float(nextValue)
            } else {
                return Float(currentValue)
            }
        } else if(value.type == TYPE_EXPR_ASSIGN) {
            let assignExpr = value.content as! AssignExpr
            let rightValue = parseExprValue(value: assignExpr.right, scope: scope)
            let setter = parseExprValue(value: assignExpr.left, scope: scope, leftValue: true)
            if assignExpr.operatorString == "=" {
                let setter = (setter as! MemberInvoker)
                setter(rightValue)
            }
            return rightValue
        }
        assert(false, "can not be empty")
    }
    
    func parseMember(obj: MemberProvider, computed: Bool, value: Node, scope: Scope) -> Any? {
        if computed {
            let name = parseExprValue(value: value, scope: scope)
            return obj.getMemeber(name: String(name as! Int))
        } else if value.type == TYPE_EXPR_ID {
            let idInfo = value.content as! IdInfo
            return obj.getMemeber(name: idInfo.name)
        }
        return nil
    }
    
    func parseMemberGetter(obj: MemberProvider, computed: Bool, value: Node, scope: Scope) -> Any? {
        if computed {
            let name = parseExprValue(value: value, scope: scope)
            if name is Float {
                return obj.memberSetter(name: String(name as! Float))
            }
            if name is Int {
                return obj.memberSetter(name: String(name as! Int))
            }
            if name is String {
                return obj.memberSetter(name: name as! String)
            }
        } else if value.type == TYPE_EXPR_ID {
            let idInfo = value.content as! IdInfo
            return obj.memberSetter(name: idInfo.name)
        }
        return nil
    }
    
    func binaryCalculate(scope: Scope, binaryData: BinaryData) -> Any? {
        let leftValue = parseExprValue(value: binaryData.left, scope: scope)
        let rightValue = parseExprValue(value: binaryData.right, scope: scope)
        switch binaryData.operatorString {
        case "+":
            if leftValue is String && rightValue is String {
                return (leftValue as! String) + (rightValue as! String)
            } else if leftValue is String {
                if rightValue is Int {
                    return (leftValue as! String) + String(rightValue as! Int)
                }
                return (leftValue as! String) + String(rightValue as! Float)
            } else if rightValue is String {
                return String(leftValue as! Float) + (rightValue as! String)
            } else {
                if leftValue is Int {
                    let value = Float((leftValue as! Int)) + (rightValue as! Float)
                    print("你好" + String(value))
                    return value
                }
                let value = (leftValue as! Float) + (rightValue as! Float)
                print("你好" + String(value))
                return value
            }
        case "-":
            return (leftValue as! Float) - (rightValue as! Float)
        case "*":
            return (leftValue as! Float) * (rightValue as! Float)
        case "/":
            return (leftValue as! Float) / (rightValue as! Float)
        case "%":
            var left: Int = 0
            var right: Int = 0
            var result: Int = 0
            if leftValue is Float {
                left = Int((leftValue as! Float))
            }else {
                left = (leftValue as! Int)
            }
            if rightValue is Float {
                right = Int((rightValue as! Float))
            }else {
                right = (rightValue as! Int)
            }
            result = left % right
            return result
        case ">":
            return (leftValue as! Float) > (rightValue as! Float)
        case ">=":
            return (leftValue as! Float) >= (rightValue as! Float)
        case "<":
            if leftValue is Float && rightValue is Float {
                return (leftValue as! Float) < (rightValue as! Float)
            }
            return Float(leftValue as! Int) < (rightValue as! Float)
        case "<=":
            return (leftValue as! Float) <= (rightValue as! Float)
        case "==":
            if leftValue is Int && rightValue is Float {
                return (leftValue as! Int) == Int(rightValue as! Float)
            }
            if leftValue is Int && rightValue is Int {
                return (leftValue as! Int) == (rightValue as! Int)
            }
            if leftValue is Float && rightValue is Int {
                return Int((leftValue as! Float)) == (rightValue as! Int)
            }
            return (leftValue as! Float) == (rightValue as! Float)
        case "!=":
            return (leftValue as! Float) != (rightValue as! Float)
        case "&&":
            return (leftValue as! Bool) && (rightValue as! Bool)
        case "||":
            return (leftValue as! Bool) || (rightValue as! Bool)
//        case "&":
////            return leftUsed & rightUsed
//            return 0
//        case "|":
//            return (leftValue as! Bool) | (rightValue as! Bool)
//        case "^":
////            return leftUsed ^ rightUsed
//            return 0
        default:
            assert(false, "not support" + binaryData.operatorString)
        }
    }
}

class Scope {
    var varList: [String : Any] = [:]
    var parentScope: Scope?
    var updateState: ((Int, Any?) -> Void)?
    var visitAndGetState: ((Any?) -> [Int : Any?])?
    var visitAndGetCallback: ((Function) -> Function)?
    var checkAndRunEffect: ((Function, JsArray) -> Void)?
    
    init(parentScope: Scope?) {
        self.parentScope = parentScope
        self.updateState = parentScope?.updateState
        self.visitAndGetState = parentScope?.visitAndGetState
        self.visitAndGetCallback = parentScope?.visitAndGetCallback
        self.checkAndRunEffect = parentScope?.checkAndRunEffect
    }
    
    func getVar(variable: String) -> Any? {
        if (varList[variable] != nil) {
            return varList[variable]
        }
        return parentScope?.getVar(variable: variable)
    }
    
    func setVar(variable: String, value: Any?) {
        if value == nil {
            varList[variable] = NSNull()
        } else {
            varList[variable] = value
        }
    }
}

class StackFrame {
    public var scope: Scope?
    
    init(parentScope: Scope, prevFrame: StackFrame?) {
        scope = Scope(parentScope: parentScope)
    }
}

typealias MemberInvoker = (Any?) -> (Void)

protocol MemberProvider {
    func getMemeber(name: String) -> Any?
    func memberSetter(name: String) -> MemberInvoker
}

class NativeMemberInvoker {
    var myCompletionHandler: (_ args: [Any?]?) -> (Any?)
    
    init(completion: @escaping completionHandler) {
        self.myCompletionHandler = completion
    }

    func call(args: [Any?]?) -> Any? {
        return myCompletionHandler(args)
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
    
    static func != (lhs: JsObject, rhs: JsObject) -> Bool {
        if lhs.fields.count != rhs.fields.count {
            return true
        }
        for (key, value) in lhs.fields {
            let rhsValue = rhs.fields[key]
            if rhsValue is Float && value is Float {
                if rhsValue as! Float != value as! Float {
                    return true
                }
            }
            if rhsValue is Int && value is Int {
                if rhsValue as! Int != value as! Int {
                    return true
                }
            }
            if rhsValue is String && value is String {
                if rhsValue as! String != value as! String {
                    return true
                }
            }
        }
        return false
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
            let index: Int = Int(name)!
            if index < list.count {
                return list[Int(name)!]
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
    
    static func != (lhs: JsArray, rhs: JsArray) -> Bool {
        if lhs.list.count != rhs.list.count {
            return true
        }
        for (index, value) in lhs.list.enumerated() {
            if value as! JsObject != rhs.list[index] as! JsObject {
                return true
            }
        }
        return false
    }
    
    static func == (lhs: JsArray, rhs: JsArray) -> Bool {
        if lhs.list.count != rhs.list.count {
            return false
        }
        for (index, value) in lhs.list.enumerated() {
            if value as! JsObject != rhs.list[index] as! JsObject {
                return false
            }
        }
        return true
    }
}

protocol Function {
    func toFunctionDecl() -> FunctionDecl
}

class JsEffect {
    var function: Function
    var lastValueList: JsArray?
    
    init(function: Function, lastValueList: JsArray?) {
        self.function = function
        self.lastValueList = lastValueList
    }
}

struct EvalView : View {
    var functionDecl: FunctionDecl!
    var parentScope: Scope?
    @State var args: [String : Any]?
    @State var evaluator: JsEvaluator
    @StateObject var recosObserve = RecosObservedObject()
    
    var body : some View {
        evaluator.ExecWithState(functionDecl: functionDecl, parentScope: (parentScope != nil) ? parentScope : evaluator.rootScope, args: args, recosObserveObject: recosObserve)
    }
}

class RecosObservedObject : ObservableObject {
    @Published var state: [Any?] = []
    @Published var callBack: [Function] = []
    @Published var effectList: [JsEffect] = []
    
    func removeAllState() -> Void {
        self.state.removeAll()
    }
        
    func updateState(value : [Any?], needUpdate: Bool) -> Void {
        if self.state.count == 0 {
            self.state = value
        }
        if needUpdate {
            self.state = value
        }
    }
    
    func updateStateItem(index : Int, value: Any?) -> Void {
        self.state[index] = value
    }
}

