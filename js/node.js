const TYPE_DECL_FUNC = 10
const TYPE_DECL_VAR = 11
const TYPE_DECL_VAR_LIST = 12
const TYPE_DECL_VAR_ARRAY_PATTERN = 13


const TYPE_EXPR_ARRAY = 100
const TYPE_EXPR_BINARY = 101
const TYPE_EXPR_UPDATE = 103
const TYPE_EXPR_CALL = 104
const TYPE_EXPR_MEMBER = 105
const TYPE_EXPR_OBJECT = 106
const TYPE_EXPR_FUNCTION = 107
const TYPE_EXPR_ID = 108
const TYPE_EXPR_ARRAY_FUNCTION = 109
const TYPE_EXPR_ASSIGN = 110
const TYPE_EXPR_Sequence = 111


const TYPE_STATEMENT_BLOCK = 200
const TYPE_STATEMENT_FOR = 201
const TYPE_STATEMENT_EXPR = 202
const TYPE_STATEMENT_IF = 203
const TYPE_STATEMENT_RETURN = 204

const TYPE_LITERAL_NUM = 301
const TYPE_LITERAL_STR = 302

const TYPE_JSX_ELEMENT = 500
const TYPE_JSX_TEXT = 501


exports.createFunctionDecl = function (name, param, isAsync, isGenerator, body){
    return {
        type: TYPE_DECL_FUNC,
        content: {
            name,
            isAsync,
            isGenerator,
            param,
            body
        }
    }
}

exports.createVarDecl = function (name, kind, init){
    return {
        type: TYPE_DECL_VAR,
        content: {
            name,kind,init
        }
    }
}

exports.createVarListDecl = function (list){
    return {
        type: TYPE_DECL_VAR_LIST,
        content: list
    }
}

exports.createVarArrayPatternDecl = function (nameList, kind, init){
    return {
        type: TYPE_DECL_VAR_ARRAY_PATTERN,
        content: {
            nameList,
            kind,
            init
        }
    }
}

exports.createBlockStatement = function (body){
    return {
        type: TYPE_STATEMENT_BLOCK,
        content: body
    }
}

exports.createStatementFor = function (init, test, update, body){
    return {
        type: TYPE_STATEMENT_FOR,
        content: {
            init, test, update, body
        }
    }
}

exports.createStatementIf = function (test, consequent, alternate){
    return {
        type: TYPE_STATEMENT_IF,
        content: {
            test,
            consequent,
            alternate
        }
    }
}

exports.createStatementExpr = function (expression){
    return {
        type: TYPE_STATEMENT_EXPR,
        content: expression
    }
}

exports.createStatementReturn = function (argument){
    return {
        type: TYPE_STATEMENT_RETURN,
        content: argument
    }
}

exports.createExprArray = function (elements) {
    return {
        type: TYPE_EXPR_ARRAY,
        content: elements
    }
}

exports.createExprCall = function (callee, arguments){
    return {
        type: TYPE_EXPR_CALL,
        content: {
            callee, arguments
        }
    }
}

exports.createExprMember = function (object, computed, property){
    return {
        type: TYPE_EXPR_MEMBER,
        content: {
            object,
            computed,
            property
        }
    }
}

exports.createExprObject = function (properties){
    return {
        type: TYPE_EXPR_OBJECT,
        content: properties
    }
}

exports.createExprBinary = function (left, operator, right){
    return {
        type: TYPE_EXPR_BINARY,
        content: {
            left: left,
            operator: operator,
            right: right
        }
    }
}

exports.createExprUpdate = function (argument, operator, prefix) {
    return {
        type: TYPE_EXPR_UPDATE,
        content: {
            argument: argument,
            operator: operator,
            prefix: prefix
        }

    }
}

exports.createExprAssign = function (left, operator, right) {
    return {
        type: TYPE_EXPR_ASSIGN,
        content: {
            left,
            operator,
            right
        }
    }
}

exports.createExprFunction = function (generator, async, params, body){
    return {
        type: TYPE_EXPR_FUNCTION,
        content: {
            generator,
            async,
            params,
            body
        }
    }
}

exports.createExprArrayFunction = function (params, body){
    return {
        type: TYPE_EXPR_ARRAY_FUNCTION,
        content: {
            params,
            body
        }
    }
}

exports.createLiteralNum = function (value, raw){
    return {
        type: TYPE_LITERAL_NUM,
        content: {
            value: value,
            raw: raw,
        }
    }
}

exports.createLiteralStr = function (value, raw){
    return {
        type: TYPE_LITERAL_STR,
        content: {
            value: value,
            raw: raw,
        }
    }
}

exports.createId = function (name){
    return {
        type: TYPE_EXPR_ID,
        content: {
            name
        }
    }
}

exports.createJSXElement = function (name, prop, children){
    return {
        type: TYPE_JSX_ELEMENT,
        content: {
            name,
            prop,
            children
        }
    }
}

exports.createJSXText = function (value){
    return {
        type: TYPE_JSX_TEXT,
        content: {
            text: value
        }
    }
}

exports.createSequenceExpr = function (value) {
    return {
        type: TYPE_EXPR_Sequence,
        content: {
            expression: value
        }
    }
}