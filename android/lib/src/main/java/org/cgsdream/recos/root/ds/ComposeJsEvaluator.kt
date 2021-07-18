package org.cgsdream.recos.root.ds

import android.os.SystemClock
import android.util.Log
import androidx.compose.runtime.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import org.cgsdream.recos.root.js.*
import kotlin.collections.HashMap

private const val TAG = "ComposeJsEvaluator"

class JsEvaluator(val dataSource: RecosDataSource) {

    fun normalEval(
        functionDecl: JsFunctionDecl,
        self: Any?,
        args: List<Any?>? = null
    ): Any? {
        val start = SystemClock.elapsedRealtime()
        val frame = JsStackFrame(functionDecl.parentScope ?: dataSource.rootScope)
        functionDecl.param?.forEachIndexed { index, node ->
            if (node.type != TYPE_EXPR_ID) {
                throw JsIllegalArgumentException("not id type")
            }
            val name = Json.decodeFromJsonElement<IdInfo>(node.content).name
            frame.scope.addVar(JsVariable(name, VariableKind.VAR, args?.getOrNull(index)))
        }
        frame.scope.addVar(JsVariable("this", VariableKind.VAR, self))
        val body = functionDecl.body
        runNode(frame, frame.scope, body)
        val ret = frame.returnValue
        Log.i(TAG, "eval ${functionDecl.name} duration = ${SystemClock.elapsedRealtime() - start}")
        return ret;
    }

    @Composable
    fun Eval(
        functionDecl: JsFunctionDecl,
        args: List<Any?>? = null
    ) {
        val coroutineScope = rememberCoroutineScope()
        val start = SystemClock.elapsedRealtime()
        val state = remember {
            mutableStateOf(arrayListOf<Any?>(), neverEqualPolicy())
        }
        val callback = remember {
            mutableStateOf(arrayListOf<JsFunctionDecl>(), structuralEqualityPolicy())
        }
        val effect = remember {
            mutableStateOf(arrayListOf<JsEffect>(), structuralEqualityPolicy())
        }

        val frame = JsStackFrame(functionDecl.parentScope ?: dataSource.rootScope)
        functionDecl.param?.forEachIndexed { index, node ->
            if (node.type != TYPE_EXPR_ID) {
                throw JsIllegalArgumentException("not id type")
            }
            val name = Json.decodeFromJsonElement<IdInfo>(node.content).name
            val variable = JsVariable(name, VariableKind.VAR, args?.getOrNull(index))
            frame.scope.addVar(variable)
        }

        var currentStateIndex = -1
        var currentCallbackIndex = -1
        var currentEffectIndex = -1

        frame.visitAndGetState = { defaultValue ->
            currentStateIndex++
            if (state.value.size > currentStateIndex) {
                currentStateIndex to state.value[currentStateIndex]
            } else {
                state.value.add(defaultValue)
                currentStateIndex to defaultValue
            }
        }
        frame.updateState = { index, value ->
            coroutineScope.launch(Dispatchers.Main.immediate) {
                val stateValue = arrayListOf<Any?>()
                for(i in 0 until state.value.size){
                    if(i != index){
                        stateValue.add(i, state.value[i])
                    }else{
                        stateValue.add(i, value)
                    }
                }
                state.value = stateValue
            }
        }

        frame.visitAndGetCallback = { defaultValue ->
            currentCallbackIndex++
            if (callback.value.size > currentCallbackIndex) {
                callback.value[currentCallbackIndex]
            } else {
                callback.value.add(defaultValue)
                defaultValue
            }
        }

        frame.checkAndRunEffect = { defaultValue, deps ->
            currentEffectIndex++
            val depValues = arrayListOf<Any?>()
            for (i in 0 until deps.itemCount()) {
                depValues.add(deps.get(i))
            }
            if (effect.value.size > currentEffectIndex) {
                val currentEffect = effect.value[currentEffectIndex]
                val lastValue = currentEffect.lastValueList
                if (lastValue?.size != depValues.size || !lastValue.containsAll(depValues)) {
                    effect.value[currentEffectIndex] = JsEffect(defaultValue, depValues)
                    coroutineScope.launch(Dispatchers.IO) {
                        normalEval(effect.value[currentCallbackIndex].function, null, null)
                    }
                }
            } else {
                effect.value.add(JsEffect(defaultValue, depValues))
                coroutineScope.launch(Dispatchers.IO) {
                    normalEval(defaultValue, null, null)
                }
            }
        }
        runNode(frame, frame.scope, functionDecl.body)
        val ret = frame.returnValue
        if (ret is RenderElement) {
            ret.Render(null)
        }
        Log.i(TAG, "eval ${functionDecl.name} duration = ${SystemClock.elapsedRealtime() - start}")
    }


    internal fun runNode(
        frame: JsStackFrame,
        scope: JsScope,
        node: Node,
    ) {
        if(frame.returnValue != JsStackFrame.unsetReturnValue){
            return
        }
        when (node.type) {
            TYPE_DECL_VAR_LIST -> {
                Json.decodeFromJsonElement<List<Node>>(node.content).forEach {
                    if (it.type == TYPE_DECL_VAR) {
                        val varItem = Json.decodeFromJsonElement<ValDecl>(it.content)
                        val kind = VariableKind.from(varItem.kind)
                        val initValue = parseExprValue(varItem.init, frame, scope).checkForJsValue()
                        val variable = JsVariable(varItem.name, kind, initValue)
                        if (kind == VariableKind.VAR) {
                            frame.scope.addVar(variable)
                        } else {
                            scope.addVar(variable)
                        }

                    } else if (it.type == TYPE_DECL_VAR_ARRAY_PATTERN) {
                        val varList = Json.decodeFromJsonElement<ArrayPatternValDecl>(it.content)
                        val initValue = parseExprValue(varList.init, frame, scope).checkForJsValue()
                        varList.nameList.forEachIndexed { i, name ->
                            val kind = VariableKind.from(varList.kind)
                            val variable = JsVariable(name, kind, (initValue as JsArray).get(i))
                            if (kind == VariableKind.VAR) {
                                frame.scope.addVar(variable)
                            } else {
                                scope.addVar(variable)
                            }
                        }
                    }
                }
            }
            TYPE_DECL_FUNC -> {
                scope.addFunction(Json.decodeFromJsonElement(node.content))
            }
            TYPE_STATEMENT_BLOCK -> {
                val blockScope = JsScope(scope)
                val content = Json.decodeFromJsonElement<List<Node>>(node.content)
                content.forEach {
                    runNode(frame, blockScope, it)
                }
            }
            TYPE_STATEMENT_FOR -> {
                val forStatement = Json.decodeFromJsonElement<ForStatement>(node.content)
                val forScope = JsScope(scope)
                runNode(frame, forScope, forStatement.init)
                while (parseExprValue(forStatement.test, frame, forScope).checkForJsValue() as? Boolean == true) {
                    runNode(frame, forScope, forStatement.body)
                    runNode(frame, forScope, forStatement.update)
                }
            }
            TYPE_EXPR_UPDATE -> {
                parseExprValue(node, frame, scope)
            }
            TYPE_STATEMENT_IF -> {
                val ifStatement = Json.decodeFromJsonElement<IfStatement>(node.content)
                val ifScope = JsScope(scope)
                if (parseExprValue(ifStatement.test, frame, ifScope).checkForJsValue() as? Boolean == true) {
                    runNode(frame, ifScope, ifStatement.consequent)
                } else {
                    val alternate = ifStatement.alternate
                    if(alternate != null){
                        runNode(frame, ifScope, alternate)
                    }
                }
            }
            TYPE_STATEMENT_RETURN -> {
                val arg = Json.decodeFromJsonElement<Node>(node.content)
                frame.returnValue = parseExprValue(arg, frame, scope).checkForJsValue()
            }
            TYPE_STATEMENT_EXPR -> {
                parseExprValue(Json.decodeFromJsonElement(node.content), frame, scope)
            }
        }
    }

    companion object {

    }
    fun parseExprValue(value: Node?, frame: JsStackFrame, scope: JsScope): Any? {
        if (value == null) {
            return null
        }
        when (value.type) {
            TYPE_LITERAL_STR -> {
                return Json.decodeFromJsonElement<StringLiteral>(value.content).value
            }
            TYPE_LITERAL_NUM -> {
                return Json.decodeFromJsonElement<NumLiteral>(value.content).value
            }
            TYPE_EXPR_FUNCTION -> {
                return Json.decodeFromJsonElement<FunctionExpr>(value.content).toJsFunctionDecl(scope)
            }
            TYPE_EXPR_ARRAY_FUNCTION -> {
                return Json.decodeFromJsonElement<FunctionArrayExpr>(value.content).toJsFunctionDecl(scope)
            }
            TYPE_EXPR_ARRAY -> {
                val ret = JsArray()
                Json.decodeFromJsonElement<List<Node>>(value.content).map {
                    ret.push(parseExprValue(it, frame, scope).checkForJsValue())
                }
                return ret
            }
            TYPE_EXPR_BINARY -> {
                return binaryCalculate(scope, frame, Json.decodeFromJsonElement(value.content))
            }
            TYPE_EXPR_ID -> {
                val name = Json.decodeFromJsonElement<IdInfo>(value.content).name
                val module = dataSource.getMemberProvider(name)
                if(module != null){
                    return module
                }
                return when (name) {
                    "useState" -> JsUseStateMethod(frame)
                    "useCallback" -> JsUseCallbackMethod(frame)
                    "useEffect" -> JsUseEffectMethod(frame)
                    else -> {
                        val variable = scope.getVar(name)
                        if (variable != null) {
                            return variable
                        }
                        return scope.getFunction(name)?.toJsFunctionDecl(scope)
                    }
                }
            }
            TYPE_EXPR_OBJECT -> {
                val properties = Json.decodeFromJsonElement<List<ObjectProperty>>(value.content)
                val obj = JsObject()
                properties.forEach {
                    val key = if (it.computed) {
                        parseExprValue(it.key, frame, scope).checkForJsValue()
                    } else {
                        if (it.key.type == TYPE_EXPR_ID) {
                            Json.decodeFromJsonElement<IdInfo>(it.key.content).name
                        } else {
                            null
                        }
                    }

                    val pValue = parseExprValue(it.value, frame, scope).checkForJsValue()
                    if (key != null) {
                        obj.setValue(key, pValue)
                    }
                }
                return obj
            }
            TYPE_EXPR_CALL -> {
                val callExpr = Json.decodeFromJsonElement<CallExpr>(value.content)
                val callee = parseExprValue(callExpr.callee, frame, scope).checkForJsValue()
                val arguments = callExpr.arguments.map {
                    parseExprValue(it, frame, scope).checkForJsValue()
                }
                if (callee is JsMethod) {
                    return callee.invoke(null, arguments)
                }else if (callee is JsMember) {
                    val jsMember = callee.obj.getMemberValue(callee.name)
                    if(jsMember is JsMethod){
                        return jsMember.invoke(callee.obj, arguments)
                    }else{
                        val functionDecl = jsMember as JsFunctionDecl
                        return normalEval(functionDecl, callee.obj, arguments)
                    }
                }else if(callee is JsFunctionDecl){
                    // TODO normal eval will loss state inject.
                    if(callee.isRecosComponent){
                        return FunctionDeclRenderElement(this, callee, arguments)
                    }else{
                        return normalEval(callee, null, arguments)
                    }

                }
                return callee
            }
            TYPE_EXPR_MEMBER -> {
                val memberExpr = Json.decodeFromJsonElement<MemberExpr>(value.content)
                val obj = parseExprValue(memberExpr.obj, frame, scope).checkForJsValue() as? JsMemberProvider ?: return null
                return parseMember(obj, memberExpr.computed, memberExpr.property, frame, scope)
            }
            TYPE_EXPR_UPDATE -> {
                val updateExpr = Json.decodeFromJsonElement<UpdateExpr>(value.content)
                val argumentName = Json.decodeFromJsonElement<IdInfo>(updateExpr.argument.content)
                val variable = scope.getVar(argumentName.name)
                val cv = variable?.getValue()
                val currentValue = if (cv is Int) cv else (cv as Float).toInt()
                val nextValue: Int = when (updateExpr.operator) {
                    "++" -> currentValue + 1
                    "--" -> currentValue - 1
                    else -> {
                        throw RuntimeException("Not supported")
                    }
                }
                variable.updateValue(nextValue)
                return if (updateExpr.prefix) {
                    nextValue
                } else {
                    currentValue
                }
            }
            TYPE_EXPR_ASSIGN -> {
                val assignExpr = Json.decodeFromJsonElement<AssignExpr>(value.content)
                val rightValue = parseExprValue(assignExpr.right, frame, scope).checkForJsValue()
                val leftValue = parseExprValue(assignExpr.left, frame, scope)
                if (assignExpr.operator == "=") {
                    if (leftValue is JsVariable) {
                        leftValue.updateValue(rightValue)
                    } else if (leftValue is JsMember) {
                        leftValue.obj.setMemberValue(leftValue.name, rightValue)
                    }
                }
                return rightValue
            }
            TYPE_JSX_ELEMENT -> {
                val jsxEl = Json.decodeFromJsonElement<JsxElement>(value.content)
                val props = HashMap<String, Any?>()
                jsxEl.prop?.forEach {
                    props[it.name] = parseExprValue(it.value, frame, scope).checkForJsValue()
                }
                return JsxRenderElement(this, jsxEl.name, props, jsxEl.children?.map {
                    when (it.type) {
                        TYPE_JSX_ELEMENT -> {
                            parseExprValue(it, frame, scope) as JsxRenderElement
                        }
                        TYPE_JSX_TEXT -> {
                            JsxValueRenderElement(Json.decodeFromJsonElement<JsxText>(it.content))
                        }
                        else -> {
                            JsxValueRenderElement(parseExprValue(it, frame, scope).checkForJsValue())
                        }
                    }

                })
            }
            else -> throw RuntimeException("not supported var parser: $value")
        }
    }

    private fun parseMember(
        obj: JsMemberProvider,
        computed: Boolean,
        value: Node,
        frame: JsStackFrame,
        scope: JsScope
    ): JsMember? {
        if (computed) {
            val name = parseExprValue(value, frame, scope).checkForJsValue()
            if (name != null) {
                return JsMember(obj, name)
            }
        } else if (value.type == TYPE_EXPR_ID) {
            val idInfo = Json.decodeFromJsonElement<IdInfo>(value.content)
            return JsMember(obj, idInfo.name)
        }
        return null
    }


    private fun binaryCalculate(scope: JsScope, frame: JsStackFrame, binaryData: BinaryData): Any? {
        val leftValue = parseExprValue(binaryData.left, frame, scope).checkForJsValue()
        val rightValue = parseExprValue(binaryData.right, frame, scope).checkForJsValue()
        when (binaryData.operator) {
            "+" -> {
                return if (leftValue is String || rightValue is String) {
                    "$leftValue$rightValue"
                } else {
                    val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                    val rightUsed =
                        if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                    return leftUsed + rightUsed
                }
            }
            "-" -> {
                val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed - rightUsed
            }
            "*" -> {
                val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed * rightUsed
            }
            "/" -> {
                val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed / rightUsed
            }
            "%" -> {
                val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed % rightUsed
            }
            ">" -> {
                val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed > rightUsed
            }
            ">=" -> {
                val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed >= rightUsed
            }
            "<" -> {
                val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed < rightUsed
            }
            "<=" -> {
                val leftUsed = if (leftValue is Int) leftValue.toFloat() else leftValue as Float
                val rightUsed = if (rightValue is Int) rightValue.toFloat() else rightValue as Float
                return leftUsed <= rightUsed
            }
            "==" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue
                return leftUsed == rightUsed
            }
            "!=" -> {
                val leftUsed = if(leftValue is Int) leftValue.toFloat() else leftValue
                val rightUsed = if(rightValue is Int) rightValue.toFloat() else rightValue
                return leftUsed != rightUsed
            }
            "&&" -> return (leftValue as Boolean) && (rightValue as Boolean)
            "||" -> return (leftValue as Boolean) || (rightValue as Boolean)
            "&" -> {
                val leftUsed = if (leftValue is Float) leftValue.toInt() else leftValue as Int
                val rightUsed = if (rightValue is Float) rightValue.toInt() else rightValue as Int
                return leftUsed and rightUsed
            }
            "|" -> {
                val leftUsed = if (leftValue is Float) leftValue.toInt() else leftValue as Int
                val rightUsed = if (rightValue is Float) rightValue.toInt() else rightValue as Int
                return leftUsed or rightUsed
            }
            "^" -> {
                val leftUsed = if (leftValue is Float) leftValue.toInt() else leftValue as Int
                val rightUsed = if (rightValue is Float) rightValue.toInt() else rightValue as Int
                return leftUsed xor rightUsed
            }
            else -> {
                throw RuntimeException("not support: ${binaryData.operator}")
            }
        }
    }
}


class JsEffect(val function: JsFunctionDecl, val lastValueList: List<Any?>? = null)

