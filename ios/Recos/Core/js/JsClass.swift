//
//  JsClass.swift
//  Recos
//
//  Created by wenhuan on 2021/7/21.
//

import Foundation

enum VariableKind: String {
    case LET = "let"
    case CONST = "const"
    case VAR = "var"
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
