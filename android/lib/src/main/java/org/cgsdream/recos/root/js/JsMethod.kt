package org.cgsdream.recos.root.js

import android.util.Log
import org.cgsdream.recos.root.ds.FunctionDecl
import org.cgsdream.recos.root.ds.JsFunctionDecl

interface JsMethod {
    fun invoke(self: Any?, args: List<Any?>?): Any?
}

class JsUseStateMethod(
    val stackFrame: JsStackFrame
) : JsMethod {

    override fun invoke(self: Any?, args: List<Any?>?): Any? {
        val stateValue = stackFrame.visitAndGetState!!(args!![0])
        val index = stateValue.first
        return JsArray().apply {
            push(stateValue.second)
            push(object : JsMethod {
                override fun invoke(self: Any?, args: List<Any?>?): Any? {
                    stackFrame.updateState!!(index, args!![0])
                    return null
                }
            })
        }
    }
}

class JsUseCallbackMethod(
    val stackFrame: JsStackFrame,
) : JsMethod {

    override fun invoke(self: Any?, args: List<Any?>?): Any? {
        return stackFrame.visitAndGetCallback!!(args!![0] as JsFunctionDecl)
    }
}

class JsUseEffectMethod(
    val stackFrame: JsStackFrame,
) : JsMethod {
    override fun invoke(self: Any?, args: List<Any?>?): Any? {
        stackFrame.checkAndRunEffect!!(args!![0] as JsFunctionDecl, args[1] as JsArray)
        return null
    }
}

class JsArrayPushMethod(val array: JsArray): JsMethod {
    override fun invoke(self: Any?, args: List<Any?>?): Any? {
        args?.forEach {
            array.push(it)
        }
        return args
    }
}