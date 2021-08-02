//
//  Node.swift
//  Example
//
//  Created by tigerAndBull on 2021/6/12.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation
import SwiftyJSON

let TYPE_DECL_FUNC = 10
let TYPE_DECL_VAR = 11
let TYPE_DECL_VAR_LIST = 12
let TYPE_DECL_VAR_ARRAY_PATTERN = 13

let TYPE_EXPR_ARRAY = 100
let TYPE_EXPR_BINARY = 101
let TYPE_EXPR_UPDATE = 103
let TYPE_EXPR_CALL = 104
let TYPE_EXPR_MEMBER = 105
let TYPE_EXPR_OBJECT = 106
let TYPE_EXPR_FUNCTION = 107
let TYPE_EXPR_ID = 108
let TYPE_EXPR_ARRAY_FUNCTION = 109
let TYPE_EXPR_ASSIGN = 110
let TYPE_EXPR_EXPRESSION = 111
let TYPE_EXPR_UNARY = 112

let TYPE_STATEMENT_BLOCK = 200
let TYPE_STATEMENT_FOR = 201
let TYPE_STATEMENT_EXPR = 202
let TYPE_STATEMENT_IF = 203
let TYPE_STATEMENT_RETURN = 204

let TYPE_LITERAL_NUM = 301
let TYPE_LITERAL_STR = 302

let TYPE_JSX_ELEMENT = 500
let TYPE_JSX_TEXT = 501

class Node {
    let type: Int
    let content: Any?
    
    init?(json: JSON) {
        
        if (json.isEmpty) {
           return nil
        }
        
        let type = json["type"].int
        self.type = type ?? 0
        let content = json["content"]
        
        switch type {
        case TYPE_DECL_FUNC:
            let functionDecl = FunctionDecl(json: content)
            self.content = functionDecl
            break
        case TYPE_DECL_VAR:
            let varDecl = ValDecl(json: content)
            self.content = varDecl
            break
        case TYPE_DECL_VAR_LIST:
            var nodes = [Node]()
            for (_, item):(String, JSON) in content {
                let node = Node(json: item)!
                nodes.append(node)
            }
            self.content = nodes
            break
        case TYPE_EXPR_ARRAY:
            var nodes = [Node]()
            for (_, item):(String, JSON) in content {
                let node = Node(json: item)!
                nodes.append(node)
            }
            self.content = nodes
            break
        case TYPE_EXPR_BINARY:
            let binary = BinaryData(json: content)
            self.content = binary
            break
        case TYPE_EXPR_UNARY:
            let unaryData = UnaryData(json: content)
            self.content = unaryData
            break
        case TYPE_EXPR_UPDATE:
            let updateExpr = UpdateExpr(json: content)
            self.content = updateExpr
            break
        case TYPE_EXPR_CALL:
            let call = CallExpr(json: content)
            self.content = call
            break
        case TYPE_EXPR_MEMBER:
            let memberExpr = MemeberExpr(json: content)
            self.content = memberExpr
            break
        case TYPE_EXPR_OBJECT:
            var propertys = [ObjectProperty]()
            for (_, item):(String, JSON) in content {
                let property = ObjectProperty(json: item)!
                propertys.append(property)
            }
            self.content = propertys
            break
        case TYPE_EXPR_FUNCTION:
            let function = FunctionExpr(json: content)
            self.content = function
            break
        case TYPE_EXPR_ID:
            let idInfo = IdInfo(json: content)
            self.content = idInfo
            break
        case TYPE_STATEMENT_BLOCK:
            var nodes = [Node]()
            for (_, item):(String, JSON) in content {
                let node = Node(json: item)!
                nodes.append(node)
            }
            self.content = nodes
            break
        case TYPE_STATEMENT_FOR:
            let forStatment = ForStatement(json: content)
            self.content = forStatment
            break
        case TYPE_STATEMENT_EXPR:
            let node = Node(json: content)
            self.content = node
            break
        case TYPE_STATEMENT_IF:
            let ifStatement = IfStatement(json: content)
            self.content = ifStatement
            break
        case TYPE_STATEMENT_RETURN:
            let node = Node(json: content)
            self.content = node
            break

        case TYPE_LITERAL_NUM:
            let num = NumLiteral(json: content)
            self.content = num
            break
        case TYPE_LITERAL_STR:
            let string = StringLiteral(json: content)
            self.content = string
            break
        case TYPE_JSX_ELEMENT:
            let jsx = JsxElement(json: content)
            self.content = jsx
            break
        case TYPE_JSX_TEXT:
            let jsxText = JsxText(json: content)
            self.content = jsxText
            break
        case TYPE_DECL_VAR_ARRAY_PATTERN:
            let arrayPattern = ArrayPatternValDecl(json: content)
            self.content = arrayPattern
        case TYPE_EXPR_ARRAY_FUNCTION:
            let functionArrayExpr = FunctionArrayExpr(json: content)
            self.content = functionArrayExpr
        case TYPE_EXPR_ASSIGN:
            let assignExpr = AssignExpr(json: content)
            self.content = assignExpr
        case TYPE_EXPR_EXPRESSION:
            let expression = SequenceExpr(json: content)
            self.content = expression
        default:
            guard
                let content = FunctionExpr(json: json["content"])
                else { return nil }
            self.content = content
            break
        }
    }
}

public struct FunctionDecl {
    let name: String
    let isAsync: Bool
    let isGenerator: Bool
    let body: Node
    var params: [Node]
    
    init?(json: JSON) {
        
        let name = json["name"].string
        let isAsync = json["isAsync"].bool
        let isGenerator = json["isGenerator"].bool
        let body = Node(json: json["body"])
        
        var params = [Node]()
        for (_, item):(String, JSON) in json["param"] {
            let node = Node(json: item)!
            params.append(node)
        }
        
        self.name = name!
        self.isAsync = isAsync ?? false
        self.isGenerator = isGenerator ?? false
        self.body = body!
        self.params = params
    }
    
    init(name: String, isAsync: Bool, isGenerator: Bool, body: Node, params: [Node]) {
        self.name = name
        self.isAsync = isAsync
        self.isGenerator = isGenerator
        self.body = body
        self.params = params
    }
    
    func toJsFunctionDecl(scope: JsScope? = nil) -> JsFunctionDecl {
        return JsFunctionDecl(name: self.name, param: self.params, body: self.body, parentScope: scope, isRecosComponent: true)
    }
}

struct FunctionExpr {
    let async: Bool
    let generator: Bool
    let body: Node
    var params: [Node]
    
    init?(json: JSON) {
        
        let async = json["async"].bool
        let generator = json["generator"].bool
        let body = Node(json: json["body"])
        
        var params = [Node]()
        for (_, item):(String, JSON) in json["params"] {
            let node = Node(json: item)!
            params.append(node)
        }
        
        self.async = async ?? false
        self.generator = generator ?? false
        self.body = body!
        self.params = params
    }
    
    func toJsFunctionDecl(scope: JsScope? = nil) -> JsFunctionDecl {
        return JsFunctionDecl(name: "FunctionExpr", param: self.params, body: self.body, parentScope: scope, isRecosComponent: false)
    }
}

struct FunctionArrayExpr {
    var params: [Node]
    var body: Node
    
    init?(json: JSON) {
        let body = Node(json: json["body"])
        var params = [Node]()
        for (_, item):(String, JSON) in json["params"] {
            let node = Node(json: item)!
            params.append(node)
        }
        self.body = body!
        self.params = params
    }
    
    func toJsFunctionDecl(scope: JsScope? = nil) -> JsFunctionDecl {
        return JsFunctionDecl(name: "FunctionArrayExpr", param: self.params, body: self.body, parentScope: scope, isRecosComponent: false)
    }
}

struct ValDecl {
    let name: String
    let kind: String
    let initNode: Node
    
    init?(json: JSON) {
        guard
            let name = json["name"].string,
            let kind = json["kind"].string,
            let initNode = Node(json: json["init"])
            else { return nil }
        
        self.name = name
        self.kind = kind
        self.initNode = initNode
    }
}

struct ArrayPatternValDecl {
    let nameList: [String]
    let kind: String
    let initNode: Node
    
    init?(json: JSON) {
        
        let kind = json["kind"].string
        let initNode = Node(json: json["init"])
        
        var nameList = [String]()
        for (_, item):(String, JSON) in json["nameList"] {
            let node = item.string!
            nameList.append(node)
        }
        
        self.nameList = nameList
        self.kind = kind!
        self.initNode = initNode!
    }
}

struct StringLiteral {
    let value: String
    let raw: String
    
    init?(json: JSON) {
        guard
            let value = json["value"].string,
            let raw = json["raw"].string
            else { return nil }
        
        self.value = value
        self.raw = raw
    }
}

struct NumLiteral {
    let value: Float
    let raw: String
    
    init?(json: JSON) {
        guard
            let value = json["value"].float,
            let raw = json["raw"].string
            else { return nil }
        
        self.value = value
        self.raw = raw
    }
}

struct BinaryData {
    let left: Node
    let operatorString: String
    let right: Node?
    
    init?(json: JSON) {

        let left = Node(json: json["left"])
        let operatorString = json["operator"].string
        let right = Node(json: json["right"])
        
        self.left = left!
        self.operatorString = operatorString!
        self.right = right
    }
}

struct UnaryData {
    let operatorString: String
    let argument: Node
    
    init?(json: JSON) {
        guard
            let operatorString = json["operator"].string,
            let argument = Node(json: json["argument"])
            else { return nil }
        
        self.operatorString = operatorString
        self.argument = argument
    }
}

struct AssignExpr {
    let left: Node
    let operatorString: String
    let right: Node
    
    init?(json: JSON) {
        guard
            let left = Node(json: json["left"]),
            let operatorString = json["operator"].string,
            let right = Node(json: json["right"])
            else { return nil }
        
        self.left = left
        self.operatorString = operatorString
        self.right = right
    }
}

struct IdInfo {
    let name: String
    
    init?(json: JSON) {
        guard
            let name = json["name"].string
            else { return nil }
        
        self.name = name
    }
}

struct ObjectProperty {
    let computed: Bool
    let method: Bool
    let key: Node
    let value: Node
    
    init?(json: JSON) {
        guard
            let computed = json["computed"].bool,
            let method = json["method"].bool,
            let key = Node(json: json["key"]),
            let value = Node(json: json["value"])
            else { return nil }
        
        self.computed = computed
        self.method = method
        self.key = key
        self.value = value
    }
}

struct CallExpr {
    let callee: Node
    let arguments: [Node]
    
    init?(json: JSON) {
        
        let callee = Node(json: json["callee"])
        var arguments = [Node]()
        for (_, item):(String, JSON) in json["arguments"] {
            let node = Node(json: item)!
            arguments.append(node)
        }
        
        self.callee = callee!
        self.arguments = arguments
    }
}

struct MemeberExpr {
    let obj: Node
    let computed: Bool
    let property: Node
    
    init?(json: JSON) {
        guard
            let obj = Node(json: json["object"]),
            let computed = json["computed"].bool,
            let property = Node(json: json["property"])
            else { return nil }
        
        self.obj = obj
        self.computed = computed
        self.property = property
    }
}

struct ForStatement {
    let initNode: Node
    let test: Node
    let update: Node
    let body: Node
    
    init?(json: JSON) {
        guard
            let initNode = Node(json: json["init"]),
            let test = Node(json: json["test"]),
            let update = Node(json: json["update"]),
            let body = Node(json: json["body"])
            else { return nil }
        
        self.initNode = initNode
        self.test = test
        self.update = update
        self.body = body
    }
}

struct UpdateExpr {
    let argument: Node
    let operatorString: String
    let prefix: Bool
    
    init?(json: JSON) {
        guard
            let argument = Node(json: json["argument"]),
            let operatorString = json["operator"].string,
            let prefix = json["prefix"].bool
            else { return nil }
        
        self.argument = argument
        self.operatorString = operatorString
        self.prefix = prefix
    }
}

struct IfStatement {
    let test: Node?
    let consequent: Node?
    let alternate: Node?
    
    init?(json: JSON) {
        let test = Node(json: json["test"])
        let consequent = Node(json: json["consequent"])
        let alternate = Node(json: json["alternate"])
        
        self.test = test
        self.consequent = consequent
        self.alternate = alternate
    }
}

struct JsxElement {
    let name: String
    let props: [JsxProp]
    let children: [Node]
    
    init?(json: JSON) {
        let name = json["name"].string
        
        var props = [JsxProp]()
        for (_, item):(String, JSON) in json["prop"] {
            let node = JsxProp(json: item)!
            props.append(node)
        }
        
        var children = [Node]()
        for (_, item):(String, JSON) in json["children"] {
            let node = Node(json: item)!
            children.append(node)
        }
        
        self.name = name!
        self.props = props
        self.children = children
    }
}

struct JsxProp {
    let name: String
    let value: Node?
    
    init?(json: JSON) {
        guard
            let name = json["name"].string
            else { return nil }
        
        self.name = name
        
        let value = Node(json: json["value"])
        self.value = value
    }
}

struct JsxText {
    let text: String
    
    init?(json: JSON) {
        guard
            let text = json["text"].string
            else { return nil }
        
        self.text = text
    }
}

struct SequenceExpr {
    let expressions: [Node]
    
    init?(json: JSON) {
        var expressions = [Node]()
        for (_, item):(String, JSON) in json["expression"] {
            let node = Node(json: item)!
            expressions.append(node)
        }
        self.expressions = expressions
    }
}
