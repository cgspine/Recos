package org.cgsdream.recos.root.js

import org.cgsdream.recos.root.ds.FunctionDecl
import org.cgsdream.recos.root.ds.JsFunctionDecl

class JsScope(
    private val parentScope: JsScope?,
    val isStackFrameScope: Boolean = false
) {
    private val varList = HashMap<String, JsVariable>()
    private val functionList = HashMap<String, FunctionDecl>()

    fun getVar(variable: String): JsVariable? {
        return varList[variable] ?: parentScope?.getVar(variable)
    }

    fun addVar(variable: JsVariable) {
        if (variable.kind == VariableKind.VAR && !isStackFrameScope) {
            throw RuntimeException("You must put var in stack frame scope.")
        }
        if (varList.containsKey(variable.name)) {
            throw JsVarExistException(variable.name)
        }
        varList[variable.name] = variable
    }

    fun getFunction(name: String): FunctionDecl? {
        return functionList[name] ?: parentScope?.getFunction(name)
    }

    fun addFunction(functionDecl: FunctionDecl) {
        functionList[functionDecl.name] = functionDecl
    }
}

class JsStackFrame(parentScope: JsScope?) {
    companion object {
        val unsetReturnValue = Object()
    }
    val scope = JsScope(parentScope, true)

    var updateState: ((Int, Any?) -> Unit)? = null
    var visitAndGetState: ((defaultValue: Any?) -> Pair<Int, Any?>)? = null
    var visitAndGetCallback: ((defaultValue: JsFunctionDecl) -> JsFunctionDecl)? = null
    var checkAndRunEffect: ((effect: JsFunctionDecl, deps: JsArray) -> Unit)? = null

    var returnValue: Any? = unsetReturnValue
}