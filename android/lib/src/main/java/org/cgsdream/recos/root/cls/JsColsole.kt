package org.cgsdream.recos.root.cls

import android.util.Log
import org.cgsdream.recos.root.js.JsMemberProvider
import org.cgsdream.recos.root.js.JsMethod

class JsColsole : JsMemberProvider {

    override fun getMemberValue(name: Any): Any? {
        if (name == "log") {
            return object : JsMethod {
                override fun invoke(self: Any?, args: List<Any?>?): Any? {
                    Log.i(args?.getOrNull(0) as? String ?: "", args?.getOrNull(1) as? String ?: "")
                    return null
                }
            }
        }
        throw RuntimeException("not supported")
    }

    override fun setMemberValue(name: Any, value: Any?) {
        throw RuntimeException("not supported")
    }
}