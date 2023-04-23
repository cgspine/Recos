#!/usr/bin/env node

// node cli.js -s ./test/hello.tsx -o ./test/hello.bundle
// node .cli.js -s ./

const fs = require('fs')
const path = require('path')
const getopts = require('getopts')
const babelParser = require('@babel/parser')
const node = require('./node')
const md5 = require('md5')


let options = getopts(process.argv.slice(2), {
    alias: {
        source: 's',
        output: 'o',
        help: 'h',
    },
    default: {
        source: '',
        output: '',
        help: false,
    }
})
console.log('cli options: ', options)
const { source, output, help } = options
console.log('source: ', source)
if (help) {
    return
}



function parseFile(sourcePath) {
    let content = fs.readFileSync(sourcePath, 'utf8')
    let sourceContent = babelParser.parse(content, {
        sourceType: "module",
        plugins: [
            "jsx",
        ]
    })
    return parse(sourceContent.program.body)
}

let content = fs.readFileSync('/Users/anwenhu/Desktop/MineProject/Recos/js/test/src/testLogic/index.tsx', 'utf8')
    let sourceContent = babelParser.parse(content, {
        sourceType: "module",
        plugins: [
            "jsx",
            "typescript",
        ]
    })
let ret = parse(sourceContent.program.body)
console.log(JSON.stringify(ret))
fs.writeFileSync(output, JSON.stringify(ret))

function parse(input){
    if(input == null){
        return null
    }
    
    if(Array.isArray(input)){
        let ret = Array(input.length)
        for(let i = 0; i < input.length; i++){
            ret[i] = parse(input[i])
        }
        return ret
    }
    if(input.type === 'FunctionDeclaration'){
        return node.createFunctionDecl(input.id.name, parse(input.params), input.async, input.generator, parse(input.body))
    }else if(input.type === 'BlockStatement'){
        return node.createBlockStatement(parse(input.body))
    }else if(input.type === 'VariableDeclaration'){
        let ret = Array(input.declarations.length)
        for(let i = 0; i < ret.length; i++){
            let decl = input.declarations[i]
            if(decl.id.type === 'Identifier'){
                ret[i] = node.createVarDecl(decl.id.name, input.kind, parse(decl.init))
            }else if(decl.id.type === 'ArrayPattern'){
                ret[i] = node.createVarArrayPatternDecl(decl.id.elements.map(item => item.name), input.kind, parse(decl.init))
            }
        }
        return node.createVarListDecl(ret)
    }else if(input.type === 'ArrayExpression'){
        return node.createExprArray(parse(input.elements))
    }else if(input.type === 'ForStatement'){
        return node.createStatementFor(parse(input.init), parse(input.test), parse(input.update), parse(input.body))
    }else if(input.type === 'NumericLiteral'){
        return node.createLiteralNum(input.value, input.extra.raw)
    }else if(input.type === 'StringLiteral'){
        return node.createLiteralStr(input.value, input.extra.raw)
    }else if(input.type === 'BinaryExpression'){
        return node.createExprBinary(parse(input.left), input.operator, parse(input.right))
    }else if(input.type === 'UpdateExpression'){
        return node.createExprUpdate(parse(input.argument), input.operator, input.prefix)
    }else if(input.type === 'AssignmentExpression'){
        return node.createExprAssign(parse(input.left), input.operator, parse(input.right))
    }else if(input.type === 'Identifier'){
        return node.createId(input.name)
    }else if(input.type === 'ExpressionStatement'){
        return node.createStatementExpr(parse(input.expression))
    }else if(input.type === 'CallExpression'){
        return node.createExprCall(parse(input.callee), parse(input.arguments))
    }else if(input.type === 'MemberExpression'){
        return node.createExprMember(parse(input.object), input.computed, parse(input.property))
    }else if(input.type === 'ObjectExpression'){
        return node.createExprObject(parse(input.properties))
    }else if(input.type === 'ObjectProperty'){
        return {
            computed: input.computed,
            method: input.method,
            key: parse(input.key),
            value: parse(input.value)
        }
    }else if(input.type === 'FunctionExpression'){
        return node.createExprFunction(input.generator, input.async, parse(input.params), parse(input.body))
    }else if(input.type === 'ArrowFunctionExpression'){
        return node.createExprArrayFunction(parse(input.params), parse(input.body))
    }else if(input.type === 'IfStatement'){
        return node.createStatementIf(parse(input.test), parse(input.consequent), parse(input.alternate))
    }else if(input.type === 'ReturnStatement'){
        return node.createStatementReturn(parse(input.argument))
    }else if(input.type === 'JSXElement'){
        let attrs = input.openingElement.attributes
        let props = Array(attrs.length)
        for(let i = 0; i < attrs.length; i++){
            props[i] = {
                name: attrs[i].name.name,
                value: null
            }
            props[i].value = parse(attrs[i].value)
        }
        return node.createJSXElement(input.openingElement.name.name, props, parse(input.children))
    }else if(input.type === 'JSXText'){
        return node.createJSXText(input.value)
    }else if(input.type === 'JSXExpressionContainer'){
        return parse(input.expression)
    }else if(input.type === 'SequenceExpression') {
        let ret = Array(input.expressions.length)
        for(let i = 0; i < ret.length; i++){
            let expr = input.expressions[i]
            ret[i] = parse(expr)
        }
        return node.createSequenceExpr(ret)
    }else if(input.type === 'UnaryExpression'){
        return node.createUnaryExpr(input.operator, parse(input.argument))
    }else {
        return null
    }
}




