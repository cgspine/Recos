#!/usr/bin/env node

// node cli.js -s ./test/hello.tsx -o ./test/hello.bundle

const fs = require('fs')
const getopts = require('getopts')
const babelParser = require('@babel/parser')
const type = require('@babel/types')


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
// console.log('cli options: ', options)
const {source, output, help} = options
if (help) {
    return
}

let content = fs.readFileSync(source, 'utf8')
let ast = babelParser.parse(content, {
    sourceType: "module",
    plugins: [
        "jsx",
    ]
})

let ret = parse(ast.program.body)
fs.writeFileSync(output, JSON.stringify(ret))

function parse(input) {
    if (input == null || typeof input === "undefined") {
        return null
    }
    if (Array.isArray(input)) {
        let ret = Array(input.length)
        for (let i = 0; i < input.length; i++) {
            ret[i] = parse(input[i])
        }
        return ret
    }

    let newNode = {
        type: input.type
    }
    if (type.isArrayExpression(input)) {
        newNode.elements = input.elements.map(element => parse(element))
    } else if (type.isAssignmentExpression(input)) {
        newNode.operator = input.operator
        newNode.left = parse(input.left)
        newNode.right = parse(input.right)
    } else if (type.isBinaryExpression(input)) {
        newNode.operator = input.operator
        newNode.left = parse(input.left)
        newNode.right = parse(input.right)
    } else if (type.isInterpreterDirective(input)) {
        newNode.value = input.value
    } else if (type.isDirective(input)) {
        newNode.value = parse(input.value)
    } else if (type.isDirectiveLiteral(input)) {
        newNode.value = input.value
    } else if (type.isBlockStatement(input)) {
        newNode.body = parse(input.body)
        newNode.directives = parse(input.directives)
    } else if (type.isBreakStatement(input)) {
        newNode.label = parse(input.label)
    } else if (type.isCallExpression(input)) {
        newNode.callee = parse(input.callee)
        newNode.arguments = parse(input.arguments)
        newNode.optional = input.optional || false
        newNode.typeArguments = parse(input.typeArguments)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isCatchClause(input)) {
        newNode.param = parse(input.param)
        newNode.body = parse(input.body)
    } else if (type.isConditionalExpression(input)) {
        newNode.test = parse(input.test)
        newNode.consequent = parse(input.consequent)
        newNode.alternate = parse(input.alternate)
    } else if (type.isContinueStatement(input)) {
        newNode.label = parse(input.label)
    } else if (type.isDoWhileStatement(input)) {
        newNode.test = parse(input.test)
        newNode.body = parse(input.body)
    } else if (type.isExpressionStatement(input)) {
        newNode.expression = parse(input.expression)
    } else if (type.isForInStatement(input)) {
        newNode.left = parse(input.left)
        newNode.right = parse(input.right)
        newNode.body = parse(input.body)
    } else if (type.isForStatement(input)) {
        newNode.init = parse(input.init)
        newNode.test = parse(input.test)
        newNode.update = parse(input.update)
        newNode.body = parse(input.body)
    } else if (type.isFunctionDeclaration(input) || type.isFunctionExpression(input)) {
        newNode.id = parse(input.id)
        newNode.params = parse(input.params)
        newNode.body = parse(input.body)
        newNode.generator = input.generator || false
        newNode.async = parse(input.init) || false
        newNode.returnType = parse(input.returnType)
        newNode.typeParameters = parse(input.typeParameters)
        if (type.isFunctionDeclaration(input)) {
            newNode.declare = parse(input.declare) || false
        }
    } else if (type.isIdentifier(input)) {
        newNode.name = input.name
        newNode.decorators = parse(input.decorators)
        newNode.optional = input.optional || false
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isIfStatement(input)) {
        newNode.test = parse(input.test)
        newNode.consequent = parse(input.consequent)
        newNode.alternate = parse(input.alternate)
    } else if (type.isLabeledStatement(input)) {
        newNode.label = parse(input.label)
        newNode.body = parse(input.body)
    } else if (type.isStringLiteral(input)) {
        newNode.value = input.value
    } else if (type.isNumericLiteral(input)) {
        newNode.value = input.value
    } else if (type.isBooleanLiteral(input)) {
        newNode.value = input.value
    } else if (type.isRegExpLiteral(input)) {
        newNode.pattern = input.pattern
        newNode.flags = input.flags
    } else if (type.isLogicalExpression(input)) {
        newNode.operator = input.operator
        newNode.left = parse(input.left)
        newNode.right = parse(input.right)
    } else if (type.isMemberExpression(input)) {
        newNode.object = parse(input.object)
        newNode.property = parse(input.property)
        newNode.computed = input.computed
        newNode.optional = input.optional || false
    } else if (type.isNewExpression(input)) {
        newNode.callee = parse(input.callee)
        newNode.arguments = parse(input.arguments)
        newNode.optional = input.optional || false
        newNode.typeArguments = parse(input.typeArguments)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isObjectExpression(input)) {
        newNode.properties = parse(input.properties)
    } else if (type.isObjectMethod(input)) {
        newNode.kind = input.kind
        newNode.key = parse(input.key)
        newNode.params = parse(input.params)
        newNode.body = parse(input.body)
        newNode.computed = input.computed
        newNode.generator = input.generator || false
        newNode.async = input.async || false
        newNode.key = parse(input.key)
        newNode.decorators = parse(input.decorators)
        newNode.returnType = parse(input.returnType)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isObjectProperty(input)) {
        newNode.key = parse(input.key)
        newNode.value = parse(input.value)
        newNode.computed = input.computed
        newNode.shorthand = input.shorthand
        newNode.decorators = parse(input.decorators)
    } else if (type.isRestElement(input)) {
        newNode.argument = parse(input.argument)
        newNode.decorators = parse(input.decorators)
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isReturnStatement(input) || type.isThrowStatement(input)) {
        newNode.argument = parse(input.argument)
    } else if (type.isSequenceExpression(input) || type.isParenthesizedExpression(input)) {
        newNode.expressions = parse(input.expressions)
    } else if (type.isSwitchCase(input)) {
        newNode.test = parse(input.test)
        newNode.consequent = parse(input.consequent)
    } else if (type.isSwitchStatement(input)) {
        newNode.discriminant = parse(input.discriminant)
        newNode.cases = parse(input.cases)
    } else if (type.isTryStatement(input)) {
        newNode.block = parse(input.block)
        newNode.handler = parse(input.handler)
        newNode.finalizer = parse(input.finalizer)
    } else if (type.isUnaryExpression(input) || type.isUpdateExpression(input)) {
        newNode.operator = input.operator
        newNode.argument = parse(input.argument)
        newNode.prefix = input.prefix
    } else if (type.isVariableDeclaration(input)) {
        newNode.kind = input.kind
        newNode.declarations = parse(input.declarations)
        newNode.declare = input.declare || false
    } else if (type.isVariableDeclarator(input)) {
        newNode.id = parse(input.id)
        newNode.init = parse(input.init)
        newNode.definite = input.definite || false
    } else if (type.isWhileStatement(input)) {
        newNode.test = parse(input.test)
        newNode.body = parse(input.body)
    } else if (type.isWithStatement(input)) {
        newNode.object = parse(input.object)
        newNode.body = parse(input.body)
    } else if (type.isAssignmentPattern(input)) {
        newNode.left = parse(input.left)
        newNode.right = parse(input.right)
        newNode.decorators = parse(input.decorators)
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isArrayPattern(input)) {
        newNode.elements = parse(input.elements)
        newNode.decorators = parse(input.decorators)
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isArrowFunctionExpression(input)) {
        newNode.params = parse(input.params)
        newNode.body = parse(input.body)
        newNode.async = input.async || false
        newNode.expression = input.expression
        newNode.generator = input.generator || false
        newNode.returnType = parse(input.returnType)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isClassBody(input)) {
        newNode.body = parse(input.body)
    } else if (type.isClassExpression(input) || type.isClassDeclaration(input)) {
        newNode.id = parse(input.id)
        newNode.superClass = parse(input.superClass)
        newNode.body = parse(input.body)
        newNode.decorators = parse(input.decorators)
        newNode.implements = parse(input.implements)
        newNode.mixins = parse(input.mixins)
        newNode.superTypeParameters = parse(input.superTypeParameters)
        newNode.typeParameters = parse(input.typeParameters)
        if (type.isClassDeclaration(input)) {
            newNode.abstract = input.abstract || false
            newNode.declare = input.declare || false
        }
    } else if (type.isExportAllDeclaration(input)) {
        newNode.source = parse(input.source)
        newNode.assertions = parse(input.assertions)
        newNode.exportKind = input.exportKind
    } else if (type.isExportDefaultDeclaration(input)) {
        newNode.declaration = parse(input.declaration)
    } else if (type.isExportNamedDeclaration(input)) {
        newNode.declaration = parse(input.declaration)
        newNode.specifiers = parse(input.specifiers)
        newNode.source = parse(input.source)
        newNode.assertions = parse(input.assertions)
        newNode.exportKind = input.exportKind
    } else if (type.isExportSpecifier(input)) {
        newNode.local = parse(input.local)
        newNode.exported = parse(input.exported)
    } else if (type.isForOfStatement(input)) {
        newNode.left = parse(input.left)
        newNode.right = parse(input.right)
        newNode.body = parse(input.body)
        newNode.await = input.await
    } else if (type.isImportDeclaration(input)) {
        newNode.specifiers = parse(input.specifiers)
        newNode.source = parse(input.source)
        newNode.assertions = parse(input.assertions)
        newNode.importKind = input.importKind
    } else if (type.isImportDefaultSpecifier(input) || type.isImportNamespaceSpecifier(input)) {
        newNode.local = parse(input.local)
    } else if (type.isImportSpecifier(input)) {
        newNode.local = parse(input.local)
        newNode.imported = parse(input.imported)
        newNode.importKind = input.importKind
    } else if (type.isMetaProperty(input)) {
        newNode.meta = parse(input.meta)
        newNode.property = parse(input.property)
    } else if (type.isClassMethod(input)) {
        newNode.kind = input.kind
        newNode.key = parse(input.key)
        newNode.params = parse(input.params)
        newNode.body = parse(input.body)
        newNode.computed = input.computed || false
        newNode.static = input.static || false
        newNode.generator = input.generator || false
        newNode.async = input.async || false
        newNode.abstract = input.abstract || false
        newNode.access = input.access
        newNode.accessibility = input.accessibility
        newNode.decorators = parse(input.decorators)
        newNode.optional = input.optional || false
        newNode.override = input.override || false
        newNode.returnType = parse(input.returnType)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isObjectPattern(input)) {
        newNode.properties = parse(input.properties)
        newNode.decorators = parse(input.decorators)
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isSpreadElement(input)) {
        newNode.argument = parse(input.argument)
    } else if (type.isTaggedTemplateExpression(input)) {
        newNode.tag = parse(input.tag)
        newNode.quasi = parse(input.quasi)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isTemplateElement(input)) {
        newNode.value = input.value
        newNode.tail = input.tail
    } else if (type.isTemplateLiteral(input)) {
        newNode.quasis = parse(input.quasis)
        newNode.expressions = parse(input.expressions)
    } else if (type.isYieldExpression(input)) {
        newNode.argument = parse(input.argument)
        newNode.delegate = input.delegate
    } else if (type.isAwaitExpression(input)) {
        newNode.argument = parse(input.argument)
    } else if (type.isBigIntLiteral(input)) {
        newNode.value = input.value
    } else if (type.isExportNamespaceSpecifier(input)) {
        newNode.exported = parse(input.exported)
    } else if (type.isOptionalMemberExpression(input)) {
        newNode.object = parse(input.object)
        newNode.property = parse(input.property)
        newNode.computed = input.computed
        newNode.optional = input.optional
    } else if (type.isOptionalCallExpression(input)) {
        newNode.callee = parse(input.callee)
        newNode.arguments = parse(input.arguments)
        newNode.optional = input.optional
        newNode.typeArguments = parse(input.typeArguments)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isArrayTypeAnnotation(input)) {
        newNode.elementType = parse(input.elementType)
    } else if (type.isBooleanLiteralTypeAnnotation(input)) {
        newNode.value = input.value
    } else if (type.isClassImplements(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isDeclareClass(input) || type.isDeclareInterface(input) || type.isInterfaceDeclaration(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.extends = parse(input.extends)
        newNode.body = parse(input.body)
        newNode.implements = parse(input.implements)
        newNode.mixins = parse(input.mixins)
    } else if (type.isDeclareFunction(input)) {
        newNode.id = parse(input.id)
        newNode.predicate = parse(input.predicate)
    } else if (type.isDeclareModule(input)) {
        newNode.id = parse(input.id)
        newNode.body = parse(input.body)
        newNode.kind = input.kind
    } else if (type.isDeclareModuleExports(input)) {
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isDeclareTypeAlias(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.right = parse(input.right)
    } else if (type.isDeclareOpaqueType(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.supertype = parse(input.supertype)
    } else if (type.isDeclareVariable(input)) {
        newNode.id = parse(input.id)
    } else if (type.isDeclareExportDeclaration(input)) {
        newNode.eclaration = parse(input.eclaration)
        newNode.specifiers = parse(input.specifiers)
        newNode.source = parse(input.source)
        newNode.default = input.default || false
    } else if (type.isDeclareExportAllDeclaration(input)) {
        newNode.source = parse(input.source)
        newNode.exportKind = input.exportKind
    } else if (type.isDeclaredPredicate(input)) {
        newNode.value = parse(input.value)
    } else if (type.isFunctionTypeAnnotation(input)) {
        newNode.typeParameters = parse(input.typeParameters)
        newNode.params = parse(input.params)
        newNode.rest = parse(input.rest)
        newNode.returnType = parse(input.returnType)
        newNode.this = parse(input.this)
    } else if (type.isFunctionTypeParam(input)) {
        newNode.name = parse(input.name)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.optional = input.optional || false
    } else if (type.isGenericTypeAnnotation(input) || type.isInterfaceExtends(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isInterfaceTypeAnnotation(input)) {
        newNode.extends = parse(input.extends)
        newNode.body = parse(input.body)
    } else if (type.isIntersectionTypeAnnotation(input)) {
        newNode.types = parse(input.types)
    } else if (type.isNullableTypeAnnotation(input)) {
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isNumberLiteralTypeAnnotation(input)) {
        newNode.value = input.value
    } else if (type.isObjectTypeAnnotation(input)) {
        newNode.properties = parse(input.properties)
        newNode.indexers = parse(input.indexers)
        newNode.callProperties = parse(input.callProperties)
        newNode.internalSlots = parse(input.internalSlots)
        newNode.exact = input.exact
        newNode.inexact = input.inexact
    } else if (type.isObjectTypeInternalSlot(input)) {
        newNode.id = parse(input.id)
        newNode.value = parse(input.value)
        newNode.optional = input.optional
        newNode.static = input.static
        newNode.method = input.method
    } else if (type.isObjectTypeCallProperty(input)) {
        newNode.value = parse(input.value)
        newNode.static = input.static
    } else if (type.isObjectTypeIndexer(input)) {
        newNode.id = parse(input.id)
        newNode.key = parse(input.key)
        newNode.value = parse(input.value)
        newNode.variance = input.variance
        newNode.static = input.static
    } else if (type.isObjectTypeProperty(input)) {
        newNode.key = parse(input.key)
        newNode.value = parse(input.value)
        newNode.variance = input.variance
        newNode.kind = input.kind
        newNode.method = input.method
        newNode.optional = input.optional
        newNode.proto = input.proto
        newNode.static = input.static
    } else if (type.isObjectTypeSpreadProperty(input)) {
        newNode.argument = parse(input.argument)
    } else if (type.isOpaqueType(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.supertype = parse(input.supertype)
        newNode.impltype = parse(input.impltype)
    } else if (type.isQualifiedTypeIdentifier(input)) {
        newNode.id = parse(input.id)
        newNode.qualification = parse(input.qualification)
    } else if (type.isStringLiteralTypeAnnotation(input)) {
        newNode.value = input.value
    } else if (type.isTupleTypeAnnotation(input)) {
        newNode.types = parse(input.types)
    } else if (type.isTypeofTypeAnnotation(input)) {
        newNode.argument = parse(input.argument)
    } else if (type.isTypeAlias(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.right = parse(input.right)
    } else if (type.isTypeAnnotation(input)) {
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isTypeCastExpression(input)) {
        newNode.expression = parse(input.expression)
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isTypeParameter(input)) {
        newNode.bound = parse(input.bound)
        newNode.default = parse(input.default)
        newNode.variance = parse(input.variance)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.name = input.name
    } else if (type.isTypeParameterDeclaration(input) || type.isTypeParameterInstantiation(input)) {
        newNode.params = parse(input.params)
    } else if (type.isUnionTypeAnnotation(input)) {
        newNode.types = parse(input.types)
    } else if (type.isVariance(input)) {
        newNode.kind = input.kind
    } else if (type.isEnumDeclaration(input)) {
        newNode.id = parse(input.id)
        newNode.body = parse(input.body)
    } else if (type.isEnumBooleanBody(input) || type.isEnumNumberBody(input) || type.isEnumStringBody(input)) {
        newNode.members = parse(input.members)
        newNode.explicitType = input.explicitType
        newNode.hasUnknownMembers = input.hasUnknownMembers
    } else if (type.isEnumSymbolBody(input)) {
        newNode.members = parse(input.members)
        newNode.hasUnknownMembers = input.hasUnknownMembers
    } else if (type.isEnumBooleanMember(input) || type.isEnumNumberMember(input) || type.isEnumStringMember(input)) {
        newNode.id = parse(input.id)
        newNode.init = parse(input.init)
    } else if (type.isEnumDefaultedMember(input)) {
        newNode.id = parse(input.id)
    } else if (type.isIndexedAccessType(input)) {
        newNode.objectType = parse(input.objectType)
        newNode.indexType = parse(input.indexType)
    } else if (type.isOptionalIndexedAccessType(input)) {
        newNode.objectType = parse(input.objectType)
        newNode.indexType = parse(input.indexType)
        newNode.optional = input.optional
    } else if (type.isJSXAttribute(input)) {
        newNode.name = parse(input.name)
        newNode.value = parse(input.value)
    } else if (type.isJSXClosingElement(input)) {
        newNode.name = parse(input.name)
    } else if (type.isJSXElement(input)) {
        newNode.openingElement = parse(input.openingElement)
        newNode.closingElement = parse(input.closingElement)
        newNode.children = parse(input.children)
        newNode.selfClosing = input.selfClosing
    } else if (type.isJSXExpressionContainer(input) || type.isJSXSpreadChild(input)) {
        newNode.expression = parse(input.expression)
    } else if (type.isJSXIdentifier(input)) {
        newNode.name = input.name
    } else if (type.isJSXMemberExpression(input)) {
        newNode.object = parse(input.object)
        newNode.property = parse(input.property)
    } else if (type.isJSXNamespacedName(input)) {
        newNode.namespace = parse(input.namespace)
        newNode.name = parse(input.name)
    } else if (type.isJSXOpeningElement(input)) {
        newNode.name = parse(input.name)
        newNode.attributes = parse(input.attributes)
        newNode.selfClosing = input.selfClosing
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isJSXSpreadAttribute(input)) {
        newNode.argument = parse(input.argument)
    } else if (type.isJSXText(input)) {
        newNode.value = input.value
    } else if (type.isJSXFragment(input)) {
        newNode.openingFragment = parse(input.openingFragment)
        newNode.closingFragment = parse(input.closingFragment)
        newNode.children = parse(input.children)
    } else if (type.isPlaceholder(input)) {
        newNode.expectedNode = input.expectedNode
        newNode.name = parse(input.name)
    } else if (type.isV8IntrinsicIdentifier(input)) {
        newNode.name = input.name
    } else if (type.isBindExpression(input)) {
        newNode.object = parse(input.object)
        newNode.callee = parse(input.callee)
    } else if (type.isClassProperty(input)) {
        newNode.key = parse(input.key)
        newNode.value = parse(input.value)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.decorators = parse(input.decorators)
        newNode.computed = input.computed || false
        newNode.static = input.static || false
        newNode.abstract = input.abstract || false
        newNode.accessibility = input.accessibility
        newNode.declare = input.declare || false
        newNode.definite = input.definite || false
        newNode.optional = input.optional || false
        newNode.override = input.override || false
        newNode.readonly = input.readonly || false
    } else if (type.isPipelineTopicExpression(input)) {
        newNode.expression = parse(input.expression)
    } else if (type.isPipelineBareFunction(input)) {
        newNode.callee = parse(input.callee)
    } else if (type.isClassPrivateProperty(input)) {
        newNode.key = parse(input.key)
        newNode.value = parse(input.value)
        newNode.decorators = parse(input.decorators)
        newNode.static = input.static || false
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isClassPrivateMethod(input)) {
        newNode.kind = input.kind
        newNode.key = parse(input.key)
        newNode.params = parse(input.params)
        newNode.body = parse(input.body)
        newNode.static = input.static || false
        newNode.abstract = input.abstract || false
        newNode.access = input.access
        newNode.accessibility = input.accessibility
        newNode.async = input.async || false
        newNode.decorators = parse(input.decorators)
        newNode.generator = input.generator || false
        newNode.optional = input.optional || false
        newNode.override = input.override || false
        newNode.returnType = parse(input.returnType)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isImportAttribute(input)) {
        newNode.key = parse(input.key)
        newNode.value = parse(input.value)
    } else if (type.isDecorator(input)) {
        newNode.expression = parse(input.expression)
    } else if (type.isDoExpression(input)) {
        newNode.body = parse(input.body)
        newNode.async = input.async || false
    } else if (type.isExportDefaultSpecifier(input)) {
        newNode.exported = parse(input.exported)
    } else if (type.isPrivateName(input)) {
        newNode.id = parse(input.id)
    } else if (type.isRecordExpression(input)) {
        newNode.properties = parse(input.properties)
    } else if (type.isTupleExpression(input)) {
        newNode.elements = parse(input.elements)
    } else if (type.isDecimalLiteral(input)) {
        newNode.value = input.value
    } else if (type.isStaticBlock(input) || type.isModuleExpression(input)) {
        newNode.body = parse(input.body)
    } else if (type.isTSParameterProperty(input)) {
        newNode.parameter = parse(input.parameter)
        newNode.accessibility = input.accessibility
        newNode.readonly = input.readonly || false
    } else if (type.isTSDeclareFunction(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.params = parse(input.params)
        newNode.returnType = parse(input.returnType)
        newNode.async = input.async || false
        newNode.declare = input.declare || false
        newNode.generator = input.generator || false
    } else if (type.isTSDeclareMethod(input)) {
        newNode.decorators = parse(input.decorators)
        newNode.key = parse(input.key)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.params = parse(input.params)
        newNode.returnType = parse(input.returnType)
        newNode.abstract = input.abstract || false
        newNode.access = input.access
        newNode.accessibility = input.accessibility
        newNode.async = input.async || false
        newNode.computed = input.computed || false
        newNode.generator = input.generator || false
        newNode.kind = input.kind
        newNode.optional = input.optional || false
        newNode.override = input.override || false
        newNode.static = input.static || false
    } else if (type.isTSQualifiedName(input)) {
        newNode.left = parse(input.left)
        newNode.right = parse(input.right)
    } else if (type.isTSCallSignatureDeclaration(input) || type.isTSConstructSignatureDeclaration(input)) {
        newNode.typeParameters = parse(input.typeParameters)
        newNode.params = parse(input.params)
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isTSPropertySignature(input)) {
        newNode.key = parse(input.key)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.initializer = parse(input.initializer)
        newNode.computed = input.computed || false
        newNode.optional = input.optional || false
        newNode.readonly = input.readonly || false
    } else if (type.isTSMethodSignature(input)) {
        newNode.key = parse(input.key)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.params = parse(input.params)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.computed = input.computed || false
        newNode.kind = input.kind
        newNode.optional = input.optional || false
    } else if (type.isTSIndexSignature(input)) {
        newNode.typeParameters = parse(input.typeParameters)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.readonly = input.readonly || false
        newNode.static = input.static || false
    } else if (type.isTSFunctionType(input)) {
        newNode.typeParameters = parse(input.typeParameters)
        newNode.parameters = parse(input.parameters)
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isTSConstructorType(input)) {
        newNode.typeParameters = parse(input.typeParameters)
        newNode.parameters = parse(input.parameters)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.abstract = input.abstract || false
    } else if (type.isTSTypeReference(input)) {
        newNode.typeName = parse(input.typeName)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isTSTypePredicate(input)) {
        newNode.parameterName = parse(input.parameterName)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.asserts = input.asserts || false
    } else if (type.isTSTypeQuery(input)) {
        newNode.exprName = parse(input.exprName)
    } else if (type.isTSTypeLiteral(input)) {
        newNode.members = parse(input.members)
    } else if (type.isTSArrayType(input) || type.isTSTupleType(input)) {
        newNode.elementType = parse(input.elementType)
    } else if (type.isTSOptionalType(input) || type.isTSRestType(input)) {
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isTSNamedTupleMember(input)) {
        newNode.label = parse(input.label)
        newNode.elementType = parse(input.elementType)
        newNode.optional = input.optional
    } else if (type.isTSUnionType(input) || type.isTSIntersectionType(input)) {
        newNode.types = parse(input.types)
    } else if (type.isTSConditionalType(input)) {
        newNode.checkType = parse(input.checkType)
        newNode.extendsType = parse(input.extendsType)
        newNode.trueType = parse(input.trueType)
        newNode.falseType = parse(input.falseType)
    } else if (type.isTSInferType(input)) {
        newNode.typeParameter = parse(input.typeParameter)
    } else if (type.isTSParenthesizedType(input)) {
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isTSTypeOperator(input)) {
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.operator = input.operator
    } else if (type.isTSIndexedAccessType(input)) {
        newNode.objectType = parse(input.objectType)
        newNode.indexType = parse(input.indexType)
    } else if (type.isTSMappedType(input)) {
        newNode.typeParameter = parse(input.typeParameter)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.nameType = parse(input.nameType)
        newNode.optional = input.optional || false
        newNode.readonly = input.readonly || false
    } else if (type.isTSLiteralType(input)) {
        newNode.literal = parse(input.literal)
    } else if (type.isTSExpressionWithTypeArguments(input)) {
        newNode.expression = parse(input.expression)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isTSInterfaceDeclaration(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.extends = parse(input.extends)
        newNode.body = parse(input.body)
        newNode.declare = input.declare || false
    } else if (type.isTSInterfaceBody(input)) {
        newNode.body = parse(input.body)
    } else if (type.isTSTypeAliasDeclaration(input)) {
        newNode.id = parse(input.id)
        newNode.typeParameters = parse(input.typeParameters)
        newNode.typeAnnotation = parse(input.typeAnnotation)
        newNode.declare = input.declare || false
    } else if (type.isTSAsExpression(input) || type.isTSTypeAssertion(input)) {
        newNode.expression = parse(input.expression)
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isTSEnumDeclaration(input)) {
        newNode.id = parse(input.id)
        newNode.members = parse(input.members)
        newNode.const = input.const || false
        newNode.declare = input.declare || false
        newNode.initializer = parse(input.initializer)
    } else if (type.isTSEnumMember(input)) {
        newNode.id = parse(input.id)
        newNode.initializer = parse(input.initializer)
    } else if (type.isTSModuleDeclaration(input)) {
        newNode.id = parse(input.id)
        newNode.body = parse(input.body)
        newNode.global = input.global || false
        newNode.declare = input.declare || false
    } else if (type.isTSModuleBlock(input)) {
        newNode.body = parse(input.body)
    } else if (type.isTSImportType(input)) {
        newNode.argument = parse(input.argument)
        newNode.qualifier = parse(input.qualifier)
        newNode.typeParameters = parse(input.typeParameters)
    } else if (type.isTSImportEqualsDeclaration(input)) {
        newNode.id = parse(input.id)
        newNode.moduleReference = parse(input.moduleReference)
        newNode.isExport = input.isExport || false
    } else if (type.isTSExternalModuleReference(input) ||
        type.isTSNonNullExpression(input) ||
        type.isTSExportAssignment(input)) {
        newNode.expression = parse(input.expression)
    } else if (type.isTSNamespaceExportDeclaration(input)) {
        newNode.id = parse(input.id)
    } else if (type.isTSTypeAnnotation(input)) {
        newNode.typeAnnotation = parse(input.typeAnnotation)
    } else if (type.isTSTypeParameterInstantiation(input) || type.isTSTypeParameterDeclaration(input)) {
        newNode.params = parse(input.params)
    } else if (type.isTSTypeParameter(input)) {
        newNode.constraint = parse(input.constraint)
        newNode.default = parse(input.default)
        newNode.name = input.name
        newNode.isExport = input.isExport || false
    }
}





