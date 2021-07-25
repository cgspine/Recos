package org.cgsdream.recos.root.ds

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement
import org.cgsdream.recos.root.js.JsScope

const val TYPE_DECL_FUNC = 10
const val TYPE_DECL_VAR = 11
const val TYPE_DECL_VAR_LIST = 12
const val TYPE_DECL_VAR_ARRAY_PATTERN = 13


const val TYPE_EXPR_ARRAY = 100
const val TYPE_EXPR_BINARY = 101
const val TYPE_EXPR_UPDATE = 103
const val TYPE_EXPR_CALL = 104
const val TYPE_EXPR_MEMBER = 105
const val TYPE_EXPR_OBJECT = 106
const val TYPE_EXPR_FUNCTION = 107
const val TYPE_EXPR_ID = 108
const val TYPE_EXPR_ARRAY_FUNCTION = 109
const val TYPE_EXPR_ASSIGN = 110
const val TYPE_EXPR_SEQUENCE = 111
const val TYPE_EXPR_UNARY = 112


const val TYPE_STATEMENT_BLOCK = 200
const val TYPE_STATEMENT_FOR = 201
const val TYPE_STATEMENT_EXPR = 202
const val TYPE_STATEMENT_IF = 203
const val TYPE_STATEMENT_RETURN = 204

const val TYPE_LITERAL_NUM = 301
const val TYPE_LITERAL_STR = 302

const val TYPE_JSX_ELEMENT = 500
const val TYPE_JSX_TEXT = 501

@Serializable
data class Node(
    @Serializable
    val type: Int,
    @Serializable
    val content: JsonElement
)

class JsFunctionDecl(
    val name: String,
    val param: List<Node>? = null,
    val body: Node,
    val parentScope: JsScope? = null,
    val isRecosComponent: Boolean = false
)

@Serializable
data class FunctionDecl(
    @Serializable
    val name: String,
    @Serializable
    val isAsync: Boolean,
    @Serializable
    val isGenerator: Boolean,
    @Serializable
    val param: List<Node>? = null,
    @Serializable
    val body: Node
){
    fun toJsFunctionDecl(scope: JsScope? = null): JsFunctionDecl {
        return JsFunctionDecl(name, param, body, scope, name[0].isUpperCase())
    }
}

@Serializable
data class FunctionExpr(
    @Serializable
    val async: Boolean,
    @Serializable
    val generator: Boolean,
    @Serializable
    val params: List<Node>? = null,
    @Serializable
    val body: Node
) {

    fun toJsFunctionDecl(scope: JsScope? = null): JsFunctionDecl {
        return JsFunctionDecl("FunctionExpr", params, body, scope)
    }
}

@Serializable
data class FunctionArrayExpr(
    @Serializable
    val params: List<Node>? = null,
    @Serializable
    val body: Node
) {

    fun toJsFunctionDecl(scope: JsScope? = null): JsFunctionDecl {
        return JsFunctionDecl("FunctionArrayExpr", params, body, scope)
    }
}

@Serializable
data class ValDecl(
    @Serializable
    val name: String,
    @Serializable
    val kind: String,
    @Serializable
    val init: Node? = null
)

@Serializable
data class ArrayPatternValDecl(
    @Serializable
    val nameList: List<String>,
    @Serializable
    val kind: String,
    @Serializable
    val init: Node? = null
)

@Serializable
data class StringLiteral(
    @Serializable
    val value: String,
    @Serializable
    val raw: String
)

@Serializable
data class NumLiteral(
    @Serializable
    val value: Float,
    @Serializable
    val raw: String
)

@Serializable
data class BinaryData(
    @Serializable
    val left: Node,
    @Serializable
    val operator: String,
    @Serializable
    val right: Node? = null
)

@Serializable
data class UnaryData(
    @Serializable
    val operator: String,
    @Serializable
    val argument: Node
)

@Serializable
data class AssignExpr(
    @Serializable
    val left: Node,
    @Serializable
    val operator: String,
    @Serializable
    val right: Node
)

@Serializable
data class IdInfo(
    @Serializable
    val name: String
)

@Serializable
data class ObjectProperty(
    @Serializable
    val computed: Boolean,
    @Serializable
    val method: Boolean,
    @Serializable
    val key: Node,
    @Serializable
    val value: Node? = null
)

@Serializable
data class CallExpr(
    @Serializable
    val callee: Node,
    @Serializable
    val arguments: List<Node>
)

@Serializable
data class MemberExpr(
    @Serializable
    @SerialName("object")
    val obj: Node,
    @Serializable
    val computed: Boolean,
    @Serializable
    val property: Node,
)

@Serializable
data class ForStatement(
    @Serializable
    val init: Node,
    @Serializable
    val test: Node,
    @Serializable
    val update: Node,
    @Serializable
    val body: Node
)

@Serializable
data class UpdateExpr(
    @Serializable
    val argument: Node,
    @Serializable
    val operator: String,
    @Serializable
    val prefix: Boolean,
)

@Serializable
data class IfStatement(
    @Serializable
    val test: Node,
    @Serializable
    val consequent: Node,
    @Serializable
    val alternate: Node? = null
)

@Serializable
data class JsxElement(
    @Serializable
    val name: String,
    @Serializable
    val prop: List<JsxProp>? = null,
    @Serializable
    val children: List<Node>? = null
)

@Serializable
data class JsxProp(
    @Serializable
    val name: String,
    @Serializable
    val value: Node? = null
)

@Serializable
data class JsxText(
    @Serializable
    val text: String,
)