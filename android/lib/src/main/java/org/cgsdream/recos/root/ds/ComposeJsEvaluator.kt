package org.cgsdream.recos.root.ds

import android.os.SystemClock
import android.util.Log
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import java.lang.StringBuilder
import java.util.*
import kotlin.collections.HashMap

private const val TAG = "ComposeJsEvaluator"
class JsEvaluator {
    internal val stack = Stack<StackFrame>()
    private val rootScope = Scope(null)

    @Composable
    fun Eval(functionDecl: FunctionDecl, parentScope: Scope? = null, args: List<Pair<String, Any?>>? = null){
        val start = SystemClock.elapsedRealtime()
        val lastFrame = stack.lastOrNull()
        val frame = StackFrame(parentScope ?: rootScope, lastFrame)
        args?.forEach {
            frame.scope.setVar(it.first, it.second)
        }
        stack.push(frame)
        val body = functionDecl.body
        Exec(node = body, scope = frame.scope)
        stack.pop()
        Log.i(TAG, "eval ${functionDecl.name} duration = ${SystemClock.elapsedRealtime() - start}")
    }

    @Composable
    private fun Exec(node: Node, scope: Scope){
        when(node.type){
            TYPE_DECL_VAR_LIST -> {
                Json.decodeFromJsonElement<List<Node>>(node.content).forEach {
                    val varItem = Json.decodeFromJsonElement<ValDecl>(it.content)
                    scope.setVar(varItem.name, parseExprValue(varItem.init, scope))
                }
            }
            TYPE_DECL_FUNC -> {
                // TODO
            }
            TYPE_STATEMENT_BLOCK -> {
                // TODO block scope to support let/var
                val content = Json.decodeFromJsonElement<List<Node>>(node.content)
                val blockScope = Scope(scope)
                content.forEach {
                    Exec(node = it, scope = blockScope)
                }
            }
            TYPE_STATEMENT_FOR -> {
                val forStatement = Json.decodeFromJsonElement<ForStatement>(node.content)
                // TODO for scope to support let/var
                val forScope = Scope(scope)
                Exec(node = forStatement.init, scope = forScope)
                while (parseExprValue(forStatement.test, forScope) as? Boolean == true){
                    Exec(node = forStatement.body, scope = forScope)
                    Exec(node = forStatement.update, scope = forScope)
                }
            }
            TYPE_EXPR_UPDATE -> {
                parseExprValue(node, scope)
            }
            TYPE_STATEMENT_IF -> {
                val ifStatement = Json.decodeFromJsonElement<IfStatement>(node.content)
                // TODO if scope to support let/var
                val ifScope = Scope(scope)
                if(parseExprValue(ifStatement.test, ifScope) as? Boolean == true){
                    Exec(node = ifStatement.consequent, scope = ifScope)
                }else{
                    Exec(node = ifStatement.alternate, scope = ifScope)
                }
            }
            TYPE_STATEMENT_RETURN -> {
                val arg = Json.decodeFromJsonElement<Node>(node.content)
                Exec(node = arg, scope = scope)
            }
            TYPE_JSX_ELEMENT -> {
                val jsxEl = Json.decodeFromJsonElement<JsxElement>(node.content)
                val props = HashMap<String, Any?>()
                jsxEl.prop?.forEach {
                    props[it.name] = parseExprValue(it.value, scope)
                }
                val count = props["count"] as? Int ?: 0
                if(jsxEl.name == "RecyclerView"){
                    LazyColumn() {
                        items(count, key = {
                            // TODO key
                            it
                        }, itemContent = { index ->
                            (props["render"] as? FunctionExpr)?.toFunctionDecl()?.let { child ->
                                val args = child.param?.mapNotNull {
                                    if(it.type != TYPE_EXPR_ID){
                                        null
                                    }else{
                                        val name = Json.decodeFromJsonElement<IdInfo>(it.content).name
                                        Pair(name, index)
                                    }
                                }
                                Eval(child, scope, args)
                            }
                        })
                    }
                }else if(jsxEl.name == "Text"){
                    val stringBuilder = StringBuilder()
                    jsxEl.children?.forEach {
                        if(it.type == TYPE_JSX_TEXT){
                            stringBuilder.append(Json.decodeFromJsonElement<JsxText>(it.content).text)
                        }else {
                            stringBuilder.append(parseExprValue(it, scope))
                        }
                    }
                    Text(stringBuilder.toString())
                }
            }
            TYPE_STATEMENT_EXPR -> {
                parseExprValue(Json.decodeFromJsonElement(node.content), scope)
            }
        }
    }

    private fun parseExprValue(value: Node?, scope: Scope): Any?{
        if(value == null){
            return null
        }
        if(value.type == TYPE_LITERAL_STR){
            return Json.decodeFromJsonElement<StringLiteral>(value.content).value
        }else if(value.type == TYPE_LITERAL_NUM){
            return Json.decodeFromJsonElement<NumLiteral>(value.content).value
        }else if(value.type == TYPE_EXPR_FUNCTION){
            return Json.decodeFromJsonElement<FunctionExpr>(value.content)
        }else if(value.type == TYPE_EXPR_ARRAY) {
            val ret = JsArray()
            Json.decodeFromJsonElement<List<Node>>(value.content).map {
                ret.push(parseExprValue(it, scope))
            }
            return ret
        }else if(value.type == TYPE_EXPR_BINARY){
            return binaryCalculate(scope, Json.decodeFromJsonElement(value.content))
        }else if(value.type == TYPE_EXPR_ID){
            return scope.getVar(Json.decodeFromJsonElement<IdInfo>(value.content).name)
        }else if(value.type == TYPE_EXPR_OBJECT){
            val properties = Json.decodeFromJsonElement<List<ObjectProperty>>(value.content)
            val obj = JsObject()
            properties.forEach {
                val key = if(it.computed){
                    parseExprValue(it.key, scope)
                }else {
                    if(it.key.type == TYPE_EXPR_ID){
                        Json.decodeFromJsonElement<IdInfo>(it.key.content).name
                    }else{
                        null
                    }
                }

                val pValue = parseExprValue(it.value, scope)
                if(key != null){
                    obj.setValue(key, pValue)
                }
            }
            return obj
        }else if(value.type == TYPE_EXPR_CALL){
            val callExpr = Json.decodeFromJsonElement<CallExpr>(value.content)
            val memberFunc = parseExprValue(callExpr.callee, scope)
            val arguments = callExpr.arguments.map {
                parseExprValue(it, scope)
            }
            return (memberFunc as? NativeMemberInvoker)?.call(arguments) ?: memberFunc
        } else if(value.type == TYPE_EXPR_MEMBER){
            val memberExpr = Json.decodeFromJsonElement<MemberExpr>(value.content)
            val obj = parseExprValue(memberExpr.obj, scope)
            val ret = parseMember(obj!!, memberExpr.computed, memberExpr.property, scope)
            return ret
        } else if(value.type == TYPE_EXPR_UPDATE){
            val updateExpr = Json.decodeFromJsonElement<UpdateExpr>(value.content)
            val argumentName = Json.decodeFromJsonElement<IdInfo>(updateExpr.argument.content)
            val cv = scope.getVar(argumentName.name)
            val currentValue = if(cv is Int) cv else (cv as Float).toInt()
            val nextValue: Int = when(updateExpr.operator){
                "++" -> currentValue + 1
                "--" -> currentValue - 1
                else -> {
                    throw RuntimeException("Not supported")
                }
            }
            scope.setVar(argumentName.name, nextValue)
            return if(updateExpr.prefix){
                nextValue
            }else{
                currentValue
            }
        }
        throw RuntimeException("not supported var parser: $value")
    }

    private fun parseMember(obj: Any, computed: Boolean, value: Node, scope: Scope): Any?{
        if(obj !is MemberProvider){
            throw RuntimeException("not a member provider. $obj")
        }

        if(computed){
            val name = parseExprValue(value, scope)
            if(name != null){
                return obj.getMember(name)
            }
        }else if(value.type == TYPE_EXPR_ID){
            val idInfo = Json.decodeFromJsonElement<IdInfo>(value.content)
            return obj.getMember(idInfo.name)
        }
        return null
    }

    private fun binaryCalculate(scope: Scope, binaryData: BinaryData): Any?{
        val leftValue = parseExprValue(binaryData.left, scope)
        val rightValue = parseExprValue(binaryData.right, scope)
        when(binaryData.operator){
            "+" -> {
                return if(leftValue is String || rightValue is String){
                    "$leftValue$rightValue"
                }else{
                    val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                    val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                    return leftUsed + rightUsed
                }
            }
            "-" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed - rightUsed
            }
            "*" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed * rightUsed
            }
            "/" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed / rightUsed
            }
            "%" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed % rightUsed
            }
            ">" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed > rightUsed
            }
            ">=" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed >= rightUsed
            }
            "<" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed < rightUsed
            }
            "<=" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed <= rightUsed
            }
            "==" -> return leftValue == rightValue
            "!=" -> return leftValue != rightValue
            "&&" -> return (leftValue as Boolean) && (rightValue as Boolean)
            "||" -> return (leftValue as Boolean) || (rightValue as Boolean)
            "&" -> {
                val leftUsed = if(leftValue is Float) leftValue.toInt() else leftValue as Int
                val rightUsed = if(rightValue is Float) rightValue.toInt() else rightValue as Int
                return leftUsed and rightUsed
            }
            "|" -> {
                val leftUsed = if(leftValue is Float) leftValue.toInt() else leftValue as Int
                val rightUsed = if(rightValue is Float) rightValue.toInt() else rightValue as Int
                return leftUsed or rightUsed
            }
            "^" -> {
                val leftUsed = if(leftValue is Float) leftValue.toInt() else leftValue as Int
                val rightUsed = if(rightValue is Float) rightValue.toInt() else rightValue as Int
                return leftUsed xor rightUsed
            }
            else -> {
                throw RuntimeException("not support: ${binaryData.operator}")
            }
        }
    }
}

class Scope(val parentScope: Scope?) {
    private val varList = HashMap<String, Any?>()

    fun getVar(variable: String): Any? {
        return varList[variable] ?: parentScope?.getVar(variable)
    }

    fun setVar(variable: String, value: Any?) {
        varList[variable] = value
    }
}

internal interface MemberProvider {
    fun getMember(name: Any): Any?
}

class JsObject: MemberProvider {
    private var fields: MutableMap<Any, Any?> = hashMapOf()

    fun getValue(variable: Any): Any? {
       return fields[variable] ?: (fields["__proto__"] as? JsObject)?.fields?.get(variable)
    }

    fun setValue(variable: Any, value: Any?) {
        fields[variable] = value
    }

    override fun getMember(name: Any): Any? {
        Log.i("cgine", "name 2 = $name; $fields")
        return fields[name]
    }
}

internal class JsArray: MemberProvider {
    private var list = arrayListOf<Any?>()

    fun push(item: Any?){
        list.add(item)
    }

    override fun getMember(name: Any): Any? {
        return when(name){
            "push" -> return object: NativeMemberInvoker {
                override fun call(args: List<Any?>?): Any? {
                    args?.forEach {
                        list.add(it)
                    }
                    return args
                }
            }
            "length" -> list.size
            else -> {
                if(name is Float){
                    return list[name.toInt()]
                }else if(name is Int){
                    return list[name]
                }else{
                    throw RuntimeException("Not supported member: $name")
                }
            }
        }
    }
}

internal interface NativeMemberInvoker {
    fun call(args: List<Any?>?): Any?
}


class StackFrame(val parentScope: Scope, val prevFrame: StackFrame?){
    val scope = Scope(parentScope)
}
