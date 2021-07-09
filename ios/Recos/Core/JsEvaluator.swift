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
    
    func Eval(functionDecl: FunctionDecl, parentScope: Scope?, args: [String : Any]?) -> AnyView {
        let lastFrame = stack.top
        let frame = StackFrame(parentScope: (parentScope != nil) ? parentScope! : rootScope, prevFrame: lastFrame)
        args?.forEach { it in
            frame.scope?.setVar(variable: it.key, value: it.value)
        }
        stack.push(frame)
        let body = functionDecl.body
        var view : AnyView?
        view = Exec(node: body, scope: frame.scope!, view: &view)
        stack.pop()
        return view!
    }
    
    func Exec(node: Node, scope: Scope, view: inout AnyView?) -> AnyView? {
        switch node.type {
        case TYPE_DECL_VAR_LIST:
            let nodeArray = node.content as! [Node]
            for item in nodeArray {
                let varItem = item.content as! ValDecl
                let value = parseExprValue(value: varItem.initNode, scope: scope)
                scope.setVar(variable: varItem.name, value: value)
            }
            return view
        case TYPE_DECL_FUNC:
            // TODO
            break
        case TYPE_STATEMENT_BLOCK:
            // TODO block scope to support let/var
            let nodeArray = node.content as! [Node]
            let blockScope = Scope(parentScope: scope)
            for item in nodeArray {
                view = Exec(node: item, scope: blockScope, view: &view)
            }
            return view
        case TYPE_STATEMENT_FOR:
            let forStatement = node.content as! ForStatement
            let forScope = Scope(parentScope: scope)
            view = Exec(node: forStatement.initNode, scope: forScope, view: &view)
            while parseExprValue(value: forStatement.test, scope: forScope) as? Bool == true {
                view = Exec(node: forStatement.body, scope: forScope, view: &view)
                view = Exec(node: forStatement.update, scope: forScope, view: &view)
            }
            return view
        case TYPE_EXPR_UPDATE:
            parseExprValue(value: node, scope: scope)
            break
        case TYPE_STATEMENT_IF:
            let ifStatement = node.content as! IfStatement
            let ifScope = Scope(parentScope: scope)
            if parseExprValue(value: ifStatement.test, scope: ifScope) as? Bool == true {
                view = Exec(node: ifStatement.consequent, scope: ifScope, view: &view)
            } else {
                view = Exec(node: ifStatement.alternate, scope: ifScope, view: &view)
            }
            return view
        case TYPE_STATEMENT_RETURN:
            let arg = node.content as! Node
            view = Exec(node: arg, scope: scope, view: &view)
            return view
        case TYPE_JSX_ELEMENT:
            let jsxElement = node.content as! JsxElement
            var props: [String : Any?] = [:]
            
            jsxElement.props.forEach({ item in
                let value = parseExprValue(value: item.value, scope: scope)
                props[item.name] = value
            })
            
            let count = props["count"] as? Int ?? 0
            
            if jsxElement.name == "RecyclerView" {
                let list = List {
                    ForEach(0..<count) { index in
                        let child = (props["render"] as? FunctionExpr)?.toFunctionDecl()
                        let args = child?.params
                        let result = self.getArgs(nodes: args!, index: index)
                        if (child != nil) {
                            self.Eval(functionDecl: child!, parentScope: scope, args: result)
                        }
                    }
                }
                return AnyView(list)
            } else if jsxElement.name == "Text" {
                var string = String()
                jsxElement.children.forEach { item in
                    if item.type == TYPE_JSX_TEXT {
                        let jsxText = item.content as! JsxText
                        string.append(jsxText.text)
                    } else {
                        let value = parseExprValue(value: item, scope: scope)
                        if (value != nil) {
                            string.append(value as! String)
                        }
                    }
                }
                print("Text: " + string)
                return AnyView(Text(string))
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
    
    @discardableResult
    func parseExprValue(value: Node, scope: Scope) -> Any? {

        if value.type == TYPE_LITERAL_STR {
            return (value.content as! StringLiteral).value
        }else if(value.type == TYPE_LITERAL_NUM) {
            return (value.content as! NumLiteral).value
        }else if(value.type == TYPE_EXPR_FUNCTION){
            return value.content as! FunctionExpr
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
            return scope.getVar(variable:(value.content as! IdInfo).name)
        }else if(value.type == TYPE_EXPR_OBJECT){
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
            
            return memberFunc
            
        } else if(value.type == TYPE_EXPR_MEMBER) {
            
            let memberExpr = value.content as! MemeberExpr
            
            let obj = parseExprValue(value: memberExpr.obj, scope: scope)
            if obj is MemberProvider {
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
            scope.setVar(variable: argumentName.name, value: nextValue)
            if updateExpr.prefix {
                return Float(nextValue)
            } else {
                return Float(currentValue)
            }
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
    
    func binaryCalculate(scope: Scope, binaryData: BinaryData) -> Any? {
        let leftValue = parseExprValue(value: binaryData.left, scope: scope)
        let rightValue = parseExprValue(value: binaryData.right, scope: scope)
        switch binaryData.operatorString {
        case "+":
            if leftValue is String && rightValue is String {
                return (leftValue as! String) + (rightValue as! String)
            }else if leftValue is String {
                if rightValue is Int {
                    return (leftValue as! String) + String(rightValue as! Int)
                }
                return (leftValue as! String) + String(rightValue as! Float)
            }else if rightValue is String {
                return String(leftValue as! Float) + (rightValue as! String)
            }else {
                return (leftValue as! Float) + (rightValue as! Float)
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
    
    init(parentScope: Scope?) {
        self.parentScope = parentScope
    }
    
    func getVar(variable: String) -> Any? {
        if (varList[variable] != nil) {
            return varList[variable]
        }
        return parentScope?.getVar(variable: variable)
    }
    
    func setVar(variable: String, value: Any?) {
        if value is Int {
            varList[variable] = (value as! Int)
        } else if value is Float {
            varList[variable] = (value as! Float)
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

protocol MemberProvider {
    func getMemeber(name: String) -> Any?
}

class NativeMemberInvoker {
    var myCompletionHandler: (_ args: [Any?]?) -> ()
    
    init(completion: @escaping completionHandler) {
        self.myCompletionHandler = completion
    }

    func call(args: [Any?]?) -> Any? {
        myCompletionHandler(args)
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
}

typealias completionHandler = (_ args: [Any?]?) -> ()

class JsArray: MemberProvider {
    
    var list = [Any?]()
    
    func push(item: Any?) -> Void {
        list.append(item)
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
}

struct Eval : View {
    var functionDecl: FunctionDecl!
    var parentScope: Scope?
    @State var args: [String : Any]?
    @State var evaluator: JsEvaluator
    
    var body : some View {
        evaluator.Eval(functionDecl: functionDecl, parentScope: parentScope, args: args)
    }
}

